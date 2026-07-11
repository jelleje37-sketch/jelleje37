# Hi — I'm Jennifer 👋  
Data & AI Engineer focused on building reliable data pipelines, optimizing Python workflows, and implementing applied AI/ML systems for production-ready analytics.

---

## Technical Toolkit

### Languages & Core Libraries
- Python (Pandas, NumPy, SciPy)
- SQL (Postgres, BigQuery) — relational modeling, window functions
- R (tidyverse) — exploratory statistics & visualization
- scikit-learn, statsmodels — classical ML & statistical modelling
- Plotly, Matplotlib, Seaborn — interactive & static visualization

### AI & Machine Learning
- Supervised learning: logistic regression, tree-based ensembles, regularization, calibration
- Model evaluation & validation: cross-validation, stratified sampling, ROC/AUC, precision/recall, calibration curves
- Feature engineering: scaling, encoding, interaction terms, domain-driven variable transformation
- Model pipelines & reproducibility: scikit-learn Pipelines, joblib, MLflow (tracking & packaging)
- Large models & generative AI: prompt engineering, embedding-based retrieval, LLM orchestration (GPT-4, Claude, Gemini)
- Agent frameworks & RAG ecosystems: exposure to LangGraph / AutoGen / CrewAI concepts, vector databases (Milvus, Pinecone, Weaviate), document chunking and semantic search
- Hyperparameter tuning: grid/random search, Bayesian optimization (Optuna)

### Developer Environment
- Version control & CI: Git, GitHub, GitHub Actions, unit testing (pytest)
- Notebooks & reproducible research: Jupyter, nbformat, papermill
- Data engineering & orchestration: ETL design, Airflow / Prefect concepts, dbt-style transformation thinking
- Containerization & deployment: Docker, lightweight app packaging for inference
- Command-line tooling, logging, and lightweight observability for pipelines

---

## Featured Engineering Projects

### Healthcare Analytics — Capstone Framework
- Objective: Build a reproducible predictive pipeline for a clinical outcome and improve baseline logistic regression performance.
- Tech stack: Python, Pandas, scikit-learn, joblib, Jupyter Notebooks
- Key contributions:
  - Engineered an end-to-end pipeline: raw ingestion → deterministic cleaning → feature engineering → model training → evaluation
  - Implemented domain-informed transformations (clinical grouping, temporal feature extraction) and robust scaling strategies
  - Integrated stratified cross-validation, threshold calibration, and calibrated probability outputs for operational use
- Result: Logistic regression accuracy improved from 0.67 → 0.79 on holdout data; evaluation includes AUC, precision/recall, and calibration analyses for stakeholder review.
- Artifacts: reproducible notebooks, serialized pipeline (joblib / MLflow-ready), evaluation dashboards (notebooks + figures). (link placeholder)

---

### Metabolic Health — Ultra-Processed Food Audit
- Objective: Engineer a scalable pipeline to quantify relationships between ultra-processed food consumption and metabolic health markers across multiple data sources.
- Tech stack: Python, Pandas (vectorized transforms), SQL for extraction, Plotly for interactive visualizations
- Key contributions:
  - Built a modular ETL to standardize heterogeneous food and clinical datasets: schema alignment, unit normalization, and provenance tracking
  - Optimized Pandas workflows (categorical dtypes, chunked IO, vectorized ops) to reduce runtime and memory footprint on mid-sized datasets
  - Constructed interactive dashboards and reproducible EDA notebooks showcasing caloric density, nutrient ratios, and cohort stratification
- Result: Delivered an audit pipeline with automated cleansing, summary metrics, and visualization artifacts suitable for research replication and stakeholder communication. (link placeholder)

---
