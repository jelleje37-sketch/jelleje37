# demos — Minimal RAG demo

This folder contains a small, self-contained Retrieval-Augmented Generation demo.

File
- rag_demo.py — One-file example that demonstrates:
  1. Document chunking
  2. Embedding with sentence-transformers
  3. In-memory FAISS index
  4. Retrieval + context construction
  5. LLM prompt + answer (OpenAI by default)

Requirements
- Python 3.8+
- See ../requirements.txt or install:
  pip install sentence-transformers faiss-cpu openai python-dotenv numpy

Run
1. Set OPENAI_API_KEY in your environment (optional — otherwise the demo will show an LLM error message).
2. python demos/rag_demo.py

Notes
- For production, replace the in-memory FAISS store with a managed vector DB (Pinecone, Milvus, Weaviate).
- To avoid external API calls, swap the call_llm function for a HuggingFace local model (instructions in the demo file).
