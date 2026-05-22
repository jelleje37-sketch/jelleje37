
# 🏃‍♂️ wearables-fitlife360 / fitlife360_activity_summary.sql

## 📋 Project Overview
This asset functions as a population-level lifestyle benchmarking engine for a consumer health-tech platform (**FitLife360**). It processes and normalizes macro-level health indicator metrics from America's Health Rankings (`america_health_rankings.ahr`), encompassing over 18,000 records of state-by-state, year-by-year, and demographic tracking data. 

In a production health-tech environment, a platform like FitLife360 utilizes this verified epidemiological data as an external baseline truth layer. It allows the platform to benchmark granular, user-generated smart device profiles (such as activity levels, sleep hygiene, and metabolic indicators) against broader regional and demographic health trends.

---

## 🧬 Data Architecture & Scope
* **Source Cloud Project:** `bigquery-public-data`
* **Target Dataset:** `america_health_rankings`
* **Target Table:** `ahr`
* **SQL Dialect:** BigQuery Standard SQL (GoogleSQL)
* **Analytical Denominator:** 18,155 historical tracking records stratified by US State, Year, and Race/Ethnicity subpopulations.

---

## 🗺️ CTE Pipeline Architecture

[bigquery-public-data.america_health_rankings.ahr]
│
┌─────────────┴─────────────┐
▼                           ▼
[CTE 1: raw_behavioral_metrics]  [CTE 2: raw_outcome_metrics]
Isolate inputs (Inactivity,       Isolate indicators (Obesity,
Sleep, Exercise Metrics)          Diabetes, Hypertension)
│                           │
▼                           ▼
[CTE 3: behavior_pivoted]        [CTE 4: outcomes_pivoted]
Long → Wide Grouped Pivot        Long → Wide Grouped Pivot
│                           │
└─────────────┬─────────────┘
▼
[CTE 5: unified_regional_benchmarks]
INNER JOIN on State + Year + Subpopulation
│
▼
[FINAL SELECT OUTPUT]
Calculates Behavioral Risk Index,
Metabolic Deficit, and Rank Stratification


---

## 📊 Analytical Indicators Extracted
The pipeline filters the long-schema database down to key physiological and behavioral signals essential for metabolic performance tracking:

| Metric Category | Source Variable Name (`value_name`) | Target Schema Column | Clinical & Analytical Significance |
| :--- | :--- | :--- | :--- |
| **Behavioral Vector** | `Physical Inactivity` | `pct_sedentary` | Establishes the sedentary baseline risk profile; highly correlated with metabolic slowing. |
| **Behavioral Vector** | `Insufficient Sleep` | `pct_sleep_deprived` | Tracks chronic circadian disruption; linked to elevated cortisol and altered glycemic control. |
| **Behavioral Vector** | `Exercise` | `pct_active_exercise` | Captures baseline physical conditioning rates. |
| **Physical Outcome** | `Obesity` | `pct_obesity` | Measures primary physiological outcome for metabolic health tracking. |
| **Physical Outcome** | `Diabetes` | `pct_diabetes` | Tracks downstream metabolic and glycemic dysregulation signatures. |
| **Physical Outcome** | `High Blood Pressure` | `pct_hypertension` | Monitors cardiovascular load and overall systemic stress. |

---

## 🛠️ Key Engineering & Design Decisions

### 1. Long-to-Wide Schema Transformation
The underlying public health dataset is stored in an unpivoted, long format where all metrics share a single column (`value_name`). To build structured entity profiles suitable for predictive modeling, the script leverages conditional `MAX(CASE WHEN...)` functions grouped by `state_name`, `year`, and `race_ethnicity` to transform records into standard, wide clinical rows.

### 2. Feature Engineering of Composite Indices
To simulate how wearable data combines disparate biometric feeds, the script engineers two custom composite metrics:
* **`behavioral_risk_index`**: The mathematical average of a cohort's inactivity and sleep deprivation rates.
* **`metabolic_deficit_score`**: An additive baseline risk score tracking the combined prevalence of obesity, diabetes, and hypertension.

### 3. Failsafe Calculations
The script embeds defensive data design patterns, utilizing `COALESCE` formatting to ensure missing or suppressed regional subpopulation values fall back to safe structural zeroes, preventing broken pipelines during downstream analysis.

### 4. Algorithmic Stratification
Concludes with an evaluation block that bucketizes geographic cohorts into three distinct performance tiers (**Tier 1: Optimal Recovery Environment** to **Tier 3: Critical Metabolic Risk Zone**) based on combined sedentary behavior and metabolic outcomes. This acts as an automated triage mechanism for targeted wellness program deployments.

---

## 🏁 How to Run
The production script is designed to run standalone in the Google BigQuery console:
1. Open the BigQuery console under your Google Cloud Platform account.
2. Ensure you have read access enabled for the `bigquery-public-data` project.
3. Paste the contents of `fitlife360_activity_summary.sql` into a new query tab and execute.

## 🔗 Related Portfolio Assets
* **Clinical Pipeline:** `clinical-data/cirrhosis_survival_cohort.sql` (Predictive EHR Cohort Building)
* **Nutritional Pipeline:** `health-nutrition/upf_metabolic_analysis.sql` (Ultra-Processed Food Metabolic Audit)
