"""
rag_demo.py

Minimal, self-contained example of a Retrieval-Augmented Generation (RAG) pipeline.
This one-file demo shows the essential steps:
  1. Prepare/normalize documents
  2. Chunk documents into passages
  3. Create embeddings (sentence-transformers)
  4. Index embeddings with FAISS (in-memory)
  5. Retrieve nearest passages for a query
  6. Generate an answer using an LLM (OpenAI by default) with retrieved context

The code is intentionally small and explicit so it can be used as a teaching/demo artifact.
It is written in a neutral "LangGraph-style" pattern (stepwise data flow) and can be extended
to integrate agent frameworks like LangGraph, AutoGen, or CrewAI.

Requirements (install in a venv):
  pip install -U pip
  pip install sentence-transformers faiss-cpu openai python-dotenv

Notes:
  - If you prefer to avoid OpenAI, replace the `call_llm` function with any LLM client (HuggingFace/transformers).
  - This demo uses in-memory FAISS; for production use consider a persistent vector DB (Milvus, Pinecone, Weaviate, etc.).

Usage:
  python demos/rag_demo.py

Set OPENAI_API_KEY in your environment or via a .env file for the LLM call to work.

"""

from typing import List, Tuple
import os
import textwrap

# Optional: load .env variables if you store keys there
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

# Embeddings
from sentence_transformers import SentenceTransformer
import numpy as np

# Vector store
import faiss

# LLM client (OpenAI as default)
import openai

# -----------------------------
# Configuration
# -----------------------------
EMBED_MODEL_NAME = os.environ.get("EMBED_MODEL_NAME", "all-MiniLM-L6-v2")
OPENAI_MODEL = os.environ.get("OPENAI_MODEL", "gpt-3.5-turbo")
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

if OPENAI_API_KEY:
    openai.api_key = OPENAI_API_KEY

# Small demo documents (replace with loading from files in real projects)
DOCUMENTS = [
    ("doc1", "Clinical study showing correlation between high caloric density and elevated fasting glucose in adults."),
    ("doc2", "Guidelines: Use temporal feature extraction for patient vitals to improve model sensitivity.") ,
    ("doc3", "Ultra-processed foods were associated with higher BMI and increased metabolic risk in cohort sample.") ,
    ("doc4", "Data pipeline notes: convert units to grams, normalize fields, and track provenance with data_manifests.") ,
]

# -----------------------------
# Helpers
# -----------------------------

def chunk_text(text: str, max_tokens: int = 200, overlap: int = 50) -> List[str]:
    """Simple chunker based on word tokens.
    For demo purposes we split by words rather than model tokens.
    """
    words = text.split()
    chunks = []
    start = 0
    while start < len(words):
        end = min(start + max_tokens, len(words))
        chunk = " ".join(words[start:end])
        chunks.append(chunk)
        start = end - overlap if end - overlap > start else end
    return chunks


def prepare_passages(documents: List[Tuple[str, str]]) -> List[Tuple[str, str]]:
    """Turn documents into (passage_id, passage_text) tuples."""
    passages = []
    for doc_id, text in documents:
        chunks = chunk_text(text, max_tokens=50, overlap=10)
        for i, c in enumerate(chunks):
            pid = f"{doc_id}_p{i}"
            passages.append((pid, c))
    return passages


# -----------------------------
# Embeddings & Indexing
# -----------------------------

def build_embeddings_index(passages: List[Tuple[str, str]], model_name: str = EMBED_MODEL_NAME):
    """Produce embeddings for passages and build an in-memory FAISS index.

    Returns:
      index: faiss.IndexFlatIP (cosine via normalized vectors)
      id_map: list of passage ids in index order
      embeddings: numpy array of vectors
    """
    print(f"Loading embedding model: {model_name}")
    model = SentenceTransformer(model_name)

    texts = [p[1] for p in passages]
    ids = [p[0] for p in passages]

    print("Computing embeddings...")
    embeddings = model.encode(texts, convert_to_numpy=True, show_progress_bar=False)

    # Normalize for cosine similarity
    faiss.normalize_L2(embeddings)

    dim = embeddings.shape[1]
    index = faiss.IndexFlatIP(dim)  # inner product on normalized vectors = cosine similarity
    index.add(embeddings)

    return index, ids, embeddings


def retrieve(index, ids: List[str], embeddings: np.ndarray, query: str, model_name: str = EMBED_MODEL_NAME, top_k: int = 3):
    """Retrieve top_k passages for a query."""
    model = SentenceTransformer(model_name)
    q_emb = model.encode([query], convert_to_numpy=True)
    faiss.normalize_L2(q_emb)

    D, I = index.search(q_emb, top_k)
    results = []
    for score, idx in zip(D[0], I[0]):
        pid = ids[idx]
        passage_text = passages_map[pid]
        results.append((pid, float(score), passage_text))
    return results


# -----------------------------
# LLM call
# -----------------------------

def call_llm(system: str, user_prompt: str, model: str = OPENAI_MODEL) -> str:
    """Call OpenAI chat completion (wrapper). Replace or extend for other providers."""
    if not OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not set. Set it in env or .env to call the LLM.")

    messages = [
        {"role": "system", "content": system},
        {"role": "user", "content": user_prompt},
    ]
    resp = openai.ChatCompletion.create(model=model, messages=messages, max_tokens=300)
    text = resp.choices[0].message.content
    return text


# -----------------------------
# Orchestrator (LangGraph-style linear flow)
# -----------------------------

def run_demo(query: str):
    global passages_map

    # 1) Prepare passages
    passages = prepare_passages(DOCUMENTS)
    passages_map = {pid: text for pid, text in passages}

    # 2) Build index
    index, ids, embeddings = build_embeddings_index(passages)

    # 3) Retrieve top passages
    retrieved = retrieve(index, ids, embeddings, query, top_k=3)

    print("\nRetrieved passages:")
    for pid, score, txt in retrieved:
        print(f"- {pid} (score={score:.4f}): {textwrap.shorten(txt, width=120)}")

    # 4) Construct prompt with context + query
    context_blocks = "\n\n".join([f"[{pid}] {txt}" for pid, score, txt in retrieved])

    system = "You are a concise assistant that answers questions using only the provided context. If the answer is not contained, say 'insufficient context'."

    user_prompt = f"Context:\n{context_blocks}\n\nQuestion: {query}\n\nProvide a short, precise answer and list the source passage ids used."

    # 5) Call LLM
    try:
        answer = call_llm(system, user_prompt)
    except Exception as e:
        answer = f"LLM call failed: {e} (If you want to run without OpenAI, replace call_llm with a local HF model.)"

    print("\nLLM Answer:\n")
    print(answer)


# -----------------------------
# Entry point
# -----------------------------
if __name__ == "__main__":
    demo_query = "How did the healthcare pipeline improve logistic regression performance?"
    print("RAG demo (LangGraph-style) — minimal example\n")
    run_demo(demo_query)
