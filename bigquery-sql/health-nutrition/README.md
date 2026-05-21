# 🗄️ BigQuery SQL — Query Catalog

> **Portfolio domain:** Health & Nutrition Data Analytics  
> **Data warehouse:** Google Cloud BigQuery (Public Datasets)  
> **Maintained by:** [@jelleje37](https://github.com/jelleje37-sketch/jelleje37)  
> **Last updated:** 2026-05-20

This catalog documents every SQL script in this folder: its purpose, the source schema it targets, the analytical questions it answers, and how it connects to the broader portfolio notebooks.

---

## 📁 Folder Structure

```
bigquery-sql/
├── health-nutrition/
│   └── upf_metabolic_analysis.sql      ← You are here
├── clinical-data/
│   └── (coming soon)
├── wearables-fitlife360/
│   └── (coming soon)
└── README.md                           ← This file
```

---

## 🥤 `health-nutrition/upf_metabolic_analysis.sql`

### Overview

A multi-CTE BigQuery Standard SQL script performing a deep-dive audit of **FDA adverse food event reports** and **Class I/II product recalls**, filtered and flagged for Ultra-Processed Food (UPF) product categories. Designed to surface demographic risk profiles and metabolic reaction patterns at scale.

| Property | Detail |
|---|---|
| **Source project** | `bigquery-public-data` |
| **Datasets** | `fda_food.food_events`, `fda_food.food_enforcement` |
| **Row scope** | ~233K event records + ~28K enforcement records |
| **SQL dialect** | BigQuery Standard SQL (GoogleSQL) |
| **Companion notebook** | [`2026-audit-ultra-processed-foods-metabolism.ipynb`](../notebooks/health-nutrition/2026-audit-ultra-processed-foods-metabolism.ipynb) |

---

### Schema Reference

#### `fda_food.food_events`

| Column | Type | Description |
|---|---|---|
| `report_number` | STRING | Unique FDA adverse event report ID |
| `products_brand_name` | STRING | Reported brand name |
| `products_industry_name` | STRING | FDA product category name |
| `products_industry_code` | STRING | FDA numerical industry code |
| `reactions` | STRING | Free-text reported symptoms / reactions |
| `outcomes` | STRING | Free-text health outcomes (hospitalisation, death, etc.) |
| `consumer_gender` | STRING | Female / Male / Not Available |
| `consumer_age` | FLOAT | Numeric age in units defined by `consumer_age_unit` |
| `consumer_age_unit` | STRING | Year(s) / Month(s) / Week(s) / Day(s) / Decade(s) |
| `date_started` | DATE | Date adverse event began |
| `date_created` | DATE | Date FDA received the report |

#### `fda_food.food_enforcement`

| Column | Type | Description |
|---|---|---|
| `recall_number` | STRING | FDA recall tracking ID |
| `classification` | STRING | Class I (critical) / Class II (moderate) / Class III (minor) |
| `recalling_firm` | STRING | Manufacturer or distributor initiating recall |
| `product_description` | STRING | Description of recalled product |
| `reason_for_recall` | STRING | Stated reason (allergens, contamination, etc.) |
| `recall_initiation_date` | DATE | Date public notification began |
| `status` | STRING | On-Going / Completed / Terminated / Pending |
| `distribution_pattern` | STRING | Geographic scope of distribution |
| `voluntary_mandated` | STRING | Voluntary vs. FDA-mandated |

---

### CTE Architecture

The script is built as a 7-stage CTE pipeline for readability, modularity, and query optimisation:

```
food_events
    │
    ▼
[CTE 1] age_standardised_events
    Age normalised → years | Gender standardised | Age brackets assigned
    │
    ▼
[CTE 2] upf_flagged_events
    REGEXP flag for UPF-aligned industry categories
    (snacks, beverages, supplements, frozen meals, etc.)
    │
    ▼
[CTE 3] severity_classified_events
    Outcome text → 3-tier severity score
    Tier 3: Critical (death, hospitalisation, disability)
    Tier 2: Moderate (ER visit, medical intervention)
    Tier 1: Mild / Other
    │
    ├──▶ [CTE 5] demographic_risk_profile   → MAIN OUTPUT
    ├──▶ [CTE 6] top_reactions_by_category  → Supplementary Query A
    └──▶ [CTE 7] annual_trend               → Supplementary Query B

food_enforcement
    │
    ▼
[CTE 4] enforcement_class_i_ii              → Supplementary Query C
```

---

### Analytical Questions Answered

| # | Question | Output CTE / Query |
|---|---|---|
| 1 | Which demographic groups (age + gender) are most affected by UPF adverse events? | `demographic_risk_profile` (main output) |
| 2 | What percentage of events per cohort reach Moderate or Critical severity? | `pct_moderate_or_critical` field |
| 3 | Which food industry categories generate the highest critical event rates? | `demographic_risk_profile` filtered by `severity_label = 'Critical'` |
| 4 | What are the top 5 reported reactions per UPF product category? | Supplementary Query A |
| 5 | How has UPF adverse event volume trended year-over-year (2004–2024)? | Supplementary Query B |
| 6 | Which firms have active or recent Class I/II food recalls? | Supplementary Query C |

---

### Key Design Decisions

**Age normalisation (CTE 1)**  
FDA reports age in mixed units (years, months, weeks, days, decades). All values are converted to a decimal years float before cohort bucketing — preventing silent grouping errors.

**UPF category detection (CTE 2)**  
Rather than relying on industry codes alone (which do not map cleanly to NOVA UPF classification), a `REGEXP_CONTAINS` pattern on `products_industry_name` captures the broadest set of UPF-aligned categories. This can be tightened by adding or removing regex terms to match your specific research definition.

**Severity tiering (CTE 3)**  
The `outcomes` field is free text with no enforced vocabulary. Regex pattern matching on medically significant terms (hospitalisation, death, disability, ER visit) provides a reproducible severity proxy. Tiers align with FDA's own adverse event seriousness definitions.

**QUALIFY window deduplication (CTE 6)**  
`TOP N per group` logic uses `ROW_NUMBER() OVER (PARTITION BY ...)` with a `QUALIFY` filter — the idiomatic BigQuery pattern that avoids a subquery wrapper.

**Supplementary queries**  
Three additional queries are included as commented blocks at the bottom of the script. Swap the final `FROM` clause or uncomment to pivot the analysis without rewriting shared CTE logic.

---

### How to Run

```sql
-- Option 1: Run the main demographic risk profile
-- Execute the full script as-is.

-- Option 2: Run the top reactions analysis
-- Comment out the final SELECT block and uncomment Supplementary Query A.

-- Option 3: Run the annual trend
-- Comment out the final SELECT block and uncomment Supplementary Query B.
```

**Estimated bytes processed:** ~45 MB (`food_events`) + ~21 MB (`food_enforcement`)  
**Recommended partition/cluster:** If loading into your own dataset, partition on `date_started` and cluster on `products_industry_code` for significant cost reduction at scale.

---

### Insights This Query Enables

- 📊 **Demographic heatmaps** — age group × gender × food category adverse event rates
- 📈 **Trend analysis** — UPF adverse event growth over two decades
- ⚠️ **Severity stratification** — proportion of critical vs. mild outcomes by product class
- 🏭 **Brand-level recall overlay** — connect reaction data with Class I/II enforcement actions
- 🔬 **Reaction taxonomy** — frequency-ranked symptom profiles per food category for metabolic pattern detection

---

### Related Portfolio Work

| Asset | Link |
|---|---|
| Analysis Notebook | [`2026-audit-ultra-processed-foods-metabolism.ipynb`](../notebooks/health-nutrition/2026-audit-ultra-processed-foods-metabolism.ipynb) |
| FitLife360 Wearables Audit | [`FitLife360_Audit/`](../FitLife360_Audit/) |
| Cirrhosis Survival Analysis | [`notebooks/clinical-data/`](../notebooks/clinical-data/) |

---

*Scripts in this catalog follow [BigQuery Standard SQL (GoogleSQL)](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax) conventions. All public dataset references use the `bigquery-public-data` project.*
