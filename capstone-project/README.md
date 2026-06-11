# 🎓 Data Analytics Capstone Project

## 📊 1️⃣ Project Title

**[Your Capstone Project Title Here]**

*Subtitle: Understanding [Key Business Problem or Research Question]*

---

## 📋 2️⃣ Executive Summary

### Purpose

[Write 1–2 paragraphs explaining:
- Why this topic matters
- Why organizations should care
- What question you wanted to answer]

**Example template:**

> Chronic disease remains a significant public health concern. This analysis explores [key factors] to provide insights that may support [business outcome] and improve [stakeholder decision-making].

---

## 🎯 3️⃣ Business Problem (Ask)

### Business Questions

What 4–6 questions drive this analysis?

1. [Question 1]
2. [Question 2]
3. [Question 3]
4. [Question 4]
5. [Question 5]
6. [Question 6]

### Stakeholders

Who benefits from these insights?

- [ ] Hospital Leadership / Healthcare Administrators
- [ ] Physicians / Clinical Teams
- [ ] Nutrition Teams
- [ ] Public Health Officials
- [ ] Insurance Providers
- [ ] Other: ________________

### Success Metrics

How will success be measured?

- [ ] Identify significant predictors
- [ ] Detect meaningful trends
- [ ] Produce actionable recommendations
- [ ] Create easy-to-understand dashboards
- [ ] Support data-driven decision making

---

## 🔧 4️⃣ Prepare

### Data Source

| Property | Details |
|----------|---------|
| **Dataset Name** | [Name] |
| **Source** | [Kaggle / BigQuery / Internal / Other] |
| **Link** | [URL] |
| **Number of Records** | [Count] |
| **Number of Variables** | [Count] |
| **Years Covered** | [Date Range] |

### Tools Used

- ✅ SQL / BigQuery
- ✅ Python / Jupyter Notebook
- ✅ Tableau
- ✅ Excel
- ✅ GitHub

### Data Dictionary

| Variable | Data Type | Description |
|----------|-----------|-------------|
| [Variable 1] | [Type] | [Description] |
| [Variable 2] | [Type] | [Description] |
| [Variable 3] | [Type] | [Description] |
| [Variable 4] | [Type] | [Description] |

---

## 🧹 5️⃣ Process

### Data Cleaning

Steps taken to prepare the data:

- [ ] Removed duplicates
- [ ] Checked for missing values
- [ ] Converted data types
- [ ] Standardized categories
- [ ] Created calculated fields
- [ ] Removed unnecessary columns

**Documentation:** See `notebooks/01_EDA_and_Cleaning.ipynb`

### SQL Cleaning Example

```sql
-- Example: Remove null values and standardize fields
SELECT *
FROM [dataset_name]
WHERE [key_column] IS NOT NULL
  AND [validation_condition]
ORDER BY [relevant_column];
```

### Feature Engineering

New variables created for analysis:

- [Feature 1]: [Description]
- [Feature 2]: [Description]
- [Feature 3]: [Description]
- [Feature 4]: [Description]

---

## 📊 6️⃣ Analyze

### Key Findings

#### Finding 1
**[Finding Title]**

- **Insight:** [What did you discover?]
- **Data Support:** [% or metric]
- **Business Impact:** [Why it matters]

#### Finding 2
**[Finding Title]**

- **Insight:** [What did you discover?]
- **Data Support:** [% or metric]
- **Business Impact:** [Why it matters]

#### Finding 3
**[Finding Title]**

- **Insight:** [What did you discover?]
- **Data Support:** [% or metric]
- **Business Impact:** [Why it matters]

#### Finding 4
**[Finding Title]**

- **Insight:** [What did you discover?]
- **Data Support:** [% or metric]
- **Business Impact:** [Why it matters]

---

## 📈 7️⃣ Visualize (Share)

### Visualization 1: [Chart Type]

**Purpose:** [What question does this answer?]

**Insight:** [What pattern or trend appears?]

![Dashboard/Chart 1](../images/visualization_1.png)

---

### Visualization 2: [Chart Type]

**Purpose:** [What question does this answer?]

**Insight:** [What pattern or trend appears?]

![Dashboard/Chart 2](../images/visualization_2.png)

---

### Visualization 3: [Chart Type]

**Purpose:** [What question does this answer?]

**Insight:** [What pattern or trend appears?]

![Dashboard/Chart 3](../images/visualization_3.png)

---

### Executive Dashboard

**What can leadership quickly learn from this dashboard?**

![Main Dashboard](../images/dashboard_main.png)

- KPI 1: [Metric and value]
- KPI 2: [Metric and value]
- Key Trend: [One-line summary]

---

## 💡 8️⃣ Insights

### Summary of Findings

1. [Insight 1]
2. [Insight 2]
3. [Insight 3]
4. [Insight 4]
5. [Insight 5]

---

## ✅ 9️⃣ Recommendations (Act)

### For [Stakeholder Group 1]

- **Recommendation 1:** [Action]
- **Recommendation 2:** [Action]
- **Expected Outcome:** [Business value]

### For [Stakeholder Group 2]

- **Recommendation 1:** [Action]
- **Recommendation 2:** [Action]
- **Expected Outcome:** [Business value]

---

## 📁 🔟 Repository Structure

```
capstone-project/
│
├── data/
│   ├── raw/
│   │   └── [dataset_name].csv
│   └── processed/
│       └── [cleaned_dataset].csv
│
├── notebooks/
│   ├── 01_EDA_and_Cleaning.ipynb
│   ├── 02_Analysis.ipynb
│   └── 03_Visualizations.ipynb
│
├── sql/
│   ├── data_cleaning.sql
│   ├── feature_engineering.sql
│   └── analysis_queries.sql
│
├── tableau/
│   ├── dashboard.twbx
│   └── dashboard_screenshots/
│
├── images/
│   ├── visualization_1.png
│   ├── visualization_2.png
│   ├── visualization_3.png
│   └── dashboard_main.png
│
├── README.md (this file)
└── LICENSE
```

---

## 🚀 1️⃣1️⃣ How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/jelleje37-sketch/jelleje37.git
   cd jelleje37/capstone-project
   ```

2. **Load the dataset**
   - Place raw data in `data/raw/`

3. **Run SQL cleaning script**
   - Execute `sql/data_cleaning.sql`

4. **Explore the notebooks**
   - Start with `notebooks/01_EDA_and_Cleaning.ipynb`
   - Continue with `notebooks/02_Analysis.ipynb`

5. **View visualizations**
   - Open `tableau/dashboard.twbx` in Tableau Public/Desktop
   - Or view PNG screenshots in `images/`

---

## 🛠️ 1️⃣2️⃣ Skills Demonstrated

This capstone project showcases:

- ✅ **Data Cleaning & Validation**
- ✅ **SQL Querying & Database Management**
- ✅ **Exploratory Data Analysis (EDA)**
- ✅ **Feature Engineering**
- ✅ **Statistical Analysis & Interpretation**
- ✅ **Data Visualization (Tableau)**
- ✅ **Python (Pandas, NumPy, Matplotlib, Plotly)**
- ✅ **Dashboard Development & Design**
- ✅ **Healthcare / Domain Analytics** *(if applicable)*
- ✅ **Business Intelligence & Storytelling**
- ✅ **Communication of Technical Insights**

---

## 🔮 1️⃣3️⃣ Future Improvements

Opportunities to extend this analysis:

- [ ] Incorporate larger or more recent datasets
- [ ] Build predictive machine learning models
- [ ] Create interactive Tableau dashboards with filters & drill-downs
- [ ] Add Python statistical testing (t-tests, chi-square, correlation)
- [ ] Integrate with BigQuery for real-time data pipelines
- [ ] Develop automated alerts for key metrics
- [ ] Expand to multiple regions or time periods
- [ ] Incorporate external datasets for enrichment

---

## 📧 Contact & Attribution

**Project Owner:** Jennifer Johnson  
**Email:** [jennifer.jjohnson.merit@gmail.com](mailto:jennifer.jjohnson.merit@gmail.com)  
**LinkedIn:** [jennifer-johnson-0b2350253](https://linkedin.com/in/jennifer-johnson-0b2350253/)  
**GitHub:** [@jelleje37-sketch](https://github.com/jelleje37-sketch)

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](../LICENSE) file for details.

---

**Last Updated:** [Date]  
**Status:** [In Progress / Complete]
