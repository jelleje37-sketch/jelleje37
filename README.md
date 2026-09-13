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

### Project Management & Governance Portfolio
[View Full Portfolio →](https://github.com/jelleje37-sketch/jelleje37/tree/main/pulsewell-pmo-portfolio)

**Digital Intake & Client Portal — 14-Week Engagement**

* **Scope & Baseline**: Led end-to-end PMO lifecycle governance for a 14-week digital intake and client portal rollout on a $41,900 cost baseline.
* **Artifact Architecture**: Produced complete 16-deliverable documentation suite across Initiation (D1–D2), Planning (D3–D8), Execution & Monitoring (D9–D14), and Closing (D15–D16).
* **Governance Controls**: Applied Earned Value Management (EVM), formal Change Control Board (CCB) evaluation for wearable health-data sync (CR-001), QA/UAT sign-offs, and Phase Gate 3 operational readiness.
* **Core Competencies**: PMBOK Lifecycle Management, RAID Logs, Agile-Waterfall Governance, Resource Allocation, and Handover Planning.

---

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

## Demos
- Minimal RAG demo: [demos/rag_demo.py](./demos/rag_demo.py) — one-file Retrieval-Augmented Generation example (chunk → embed → FAISS → retrieve → LLM).  


## Data Visualization & Business Intelligence

I design automated reporting systems and interactive business dashboards that convert complex ETL data streams into actionable decision support. My work focuses on analytics engineering best practices, automated data pipelines, and scalable BI infrastructure.

| Dashboard Focus | Core Architecture | Key Business Metric Impact |
|---|---|---|
| **Operations Dashboard & Data Automation**<br>Live Portfolio: [Tableau Public Profile](https://public.tableau.com/app/profile/jennifer.johnson8039) | **Tableau** • SQL queries • Advanced Excel | Reduced reporting overhead by 40% through automated morning ETL (7:00 AM EST SLA) |
| **Wellness & Lifecycle Cohort Audit**<br>Live Portfolio: [Data Analytics Portfolio](https://sites.google.com/view/jenniferjohnsondataanalytics/home) | **R (Tidyr, ggplot2)** • Exploratory data analysis | Segmented 50K+ customer records into actionable wellness cohorts |
| **Healthcare Predictive Risk Framework**<br>Live Code: [GitHub Repository](https://github.com/jelleje37-sketch/jelleje37/blob/main/HEALTHCARE_ANALYTICS_PORTFOLIO.md) | **Python** • Feature Engineering • scikit-learn | Improved predictive accuracy from 67% → 79% on holdout validation sets |
| **E-Commerce & Digital Product KPI Tracker**<br>Live Portfolio: [Data Analytics Portfolio](https://sites.google.com/view/jenniferjohnsondataanalytics/home) | **Tableau** • Google BigQuery • dbt models | Real-time KPI tracking across 8+ digital product lines with drill-down analytics |

**Data Operations Note:** Dashboards are engineered to ingest automated morning ETL pipeline runs (scheduled via cron/Airflow) with an expected 7:00 AM EST data readiness SLA.

_Note: For live, interactive dashboard sheets and expanded data storytelling artifacts, visit my [Data Analytics Portfolio](https://sites.google.com/view/jenniferjohnsondataanalytics/home)._
