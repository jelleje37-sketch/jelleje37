🏥 clinical-data/cirrhosis_survival_cohort.sql
Overview
A 9-CTE BigQuery Standard SQL script that constructs a clean, analysis-ready clinical baseline cohort of cirrhosis patients from the FHIR Synthea synthetic EHR dataset (1.17M patients, 209M observations). The script extracts confirmed cirrhosis diagnoses via ICD-10, pivots the three core hepatic biomarkers from the deeply nested FHIR observation table, stratifies each biomarker into clinical risk tiers using validated Child-Pugh thresholds, flags three major complications via SNOMED CT, and produces a composite severity score aligned to Child-Pugh classes A / B / C. Designed to feed directly into Kaplan-Meier survival curves and machine learning survival models in the companion Jupyter notebook.

Property
Detail
Source project
bigquery-public-data
Dataset
fhir_synthea
Tables joined
patient, condition, observation
Patient pool
1,176,837 synthetic EHR patients
Observation pool
209,771,821 FHIR observations
SQL dialect
BigQuery Standard SQL (GoogleSQL)
Companion notebook
cirrhosis-survival-analysis-and-predictive-model.ipynb



Schema Reference
fhir_synthea.patient (key fields used)
Field Path
Type
Description
id
STRING
Unique patient identifier
birthDate
STRING
Date of birth (YYYY-MM-DD string)
gender
STRING
male / female / other / unknown
deceased.boolean
BOOLEAN
True if patient is deceased
deceased.dateTime
STRING
ISO 8601 death datetime
us_core_race.text.value.string
STRING
Race (FHIR extension)
us_core_ethnicity.text.value.string
STRING
Ethnicity (FHIR extension)
meta.lastUpdated
TIMESTAMP
Last record update (censoring date proxy)

fhir_synthea.condition (key fields used)
Field Path
Type
Description
id
STRING
Condition record ID
subject.patientId
STRING
Foreign key → patient.id
code.coding
REPEATED RECORD
ICD-10 / SNOMED code array
code.coding[].system
STRING
Terminology system URI
code.coding[].code
STRING
Diagnosis code
verificationStatus
STRING
confirmed / unconfirmed / refuted
onset.dateTime
STRING
Condition onset datetime
assertedDate
STRING
Date condition was recorded

fhir_synthea.observation (key fields used)
Field Path
Type
Description
id
STRING
Observation record ID
subject.patientId
STRING
Foreign key → patient.id
code.coding
REPEATED RECORD
LOINC code array
code.coding[].system
STRING
http://loinc.org
code.coding[].code
STRING
LOINC code (e.g. 1975-2)
value.quantity.value
FLOAT
Numeric lab result
value.quantity.unit
STRING
Unit of measure
effective.dateTime
STRING
Observation datetime
status
STRING
final / amended / corrected



Clinical Code Reference
ICD-10 Cirrhosis Codes (CTE 1)
Code
Description
K74.0
Hepatic fibrosis
K74.1
Hepatic sclerosis
K74.2
Hepatic fibrosis with hepatic sclerosis
K74.3
Primary biliary cirrhosis
K74.4
Secondary biliary cirrhosis
K74.5
Biliary cirrhosis, unspecified
K74.6
Other and unspecified cirrhosis of liver

LOINC Biomarker Codes (CTEs 4–6)
LOINC Code
Biomarker
Unit
Clinical Significance
1975-2
Bilirubin, Total
mg/dL
Liver excretory function; elevated = hepatocellular damage
1751-7
Albumin
g/dL
Hepatic synthesis capacity; low = chronic dysfunction
5902-2
Prothrombin Time
seconds
Coagulation factor synthesis; prolonged = severe disease

SNOMED CT Complication Codes (CTE 8)
SNOMED Code
Complication
Significance
389026000
Ascites
Fluid accumulation from portal hypertension
13920009
Hepatic encephalopathy
Neurocognitive impairment from liver failure
28670008
Oesophageal varices
High-risk bleeding complication



Child-Pugh Risk Tier Thresholds (CTE 7)
Biomarker
Low Risk (1 pt)
Moderate Risk (2 pts)
High Risk (3 pts)
Bilirubin (mg/dL)
< 2.0
2.0 – 3.0
> 3.0
Albumin (g/dL)
≥ 3.5
2.8 – 3.4
< 2.8
Prothrombin Time (sec)
< 14
14 – 17
> 17


Albumin is intentionally inverted: higher values indicate better hepatic synthetic function.


Composite Severity Score & Class Mapping (CTE 9)
Component
Points Range
Bilirubin Child-Pugh points
1 – 3
Albumin Child-Pugh points
1 – 3
Prothrombin Time Child-Pugh points
1 – 3
Ascites flag
0 – 1
Encephalopathy flag
0 – 1
Variceal bleed flag
0 – 1
Total composite score
3 – 12


Severity Class
Score Range
Clinical Interpretation
Class A — Low
3 – 5 pts
Compensated cirrhosis; favourable prognosis
Class B — Moderate
6 – 9 pts
Significant functional compromise
Class C — High
10 – 12 pts
Decompensated cirrhosis; poor prognosis
Unscored
0 pts
Insufficient biomarker data for scoring



CTE Architecture
fhir_synthea.condition

    │

    ▼

[CTE 1] cirrhosis_patients

    ICD-10 K74.x filter | verificationStatus = confirmed

    Earliest onset date → T0 (diagnosis date)

    │

    ▼ JOIN fhir_synthea.patient

[CTE 2] patient_demographics

    Age at diagnosis | Vital status | Survival days raw

    │

    ▼

[CTE 3] cleaned_demographics

    Survival days clamped (0–36,500) | Age bands assigned

    Implausible value flags added

    │

    ├──────────────────────────────────────┐

    │                                      │

    ▼ JOIN fhir_synthea.observation        ▼ JOIN fhir_synthea.condition

[CTE 4] biomarker_observations_raw    [CTE 8] complication_flags

    CROSS JOIN UNNEST code.coding          SNOMED ascites / encephalopathy /

    LOINC 1975-2 / 1751-7 / 5902-2        variceal bleed detection

    │

    ▼

[CTE 5] biomarker_most_recent

    QUALIFY ROW_NUMBER dedup → latest obs per patient × LOINC

    │

    ▼

[CTE 6] biomarkers_pivoted

    Long → Wide pivot (conditional MAX aggregation)

    │

    ▼

[CTE 7] biomarker_risk_tiers

    Child-Pugh thresholds → tier labels + CP points

    │

    ▼ JOIN CTEs 3 + 7 + 8

[CTE 9] severity_scored_cohort        → MAIN OUTPUT

    Composite score + severity class

    One row per patient, all fields joined


Analytical Questions Answered
#
Question
Output
1
Who are the confirmed cirrhosis patients and when were they diagnosed?
CTE 1 + 2
2
What is each patient's survival duration from diagnosis?
survival_days field (clamped + flagged)
3
What are each patient's most recent Bilirubin, Albumin, and Prothrombin values?
CTEs 4–6
4
Which risk tier does each biomarker fall into per Child-Pugh criteria?
*_risk_tier fields (CTE 7)
5
Which patients have ascites, encephalopathy, or variceal bleeding?
has_* flag fields (CTE 8)
6
What is each patient's composite severity class (A / B / C)?
severity_class final output
7
How does survival differ across Child-Pugh severity classes?
Supplementary Query A
8
How are biomarkers distributed within each severity class?
Supplementary Query B
9
How frequently do the three complications co-occur?
Supplementary Query C



Key Design Decisions
FHIR nested struct traversal (CTEs 4–5) FHIR R4 stores coded values in deeply nested REPEATED RECORD arrays. The script uses CROSS JOIN UNNEST(obs.code.coding) to flatten the coding array, then filters by coding.system before matching coding.code. This avoids false matches from the same code appearing in different terminology systems.

LOINC over SNOMED for biomarkers Lab observations in Synthea are coded under http://loinc.org. SNOMED CT is reserved for the complication condition detection in CTE 8, matching real-world EHR coding practice where labs use LOINC and diagnoses use SNOMED/ICD-10.

QUALIFY for deduplication (CTE 5) ROW_NUMBER() OVER (PARTITION BY patient_id, loinc_code ORDER BY observation_date DESC) with QUALIFY = 1 selects the most recent observation per patient per biomarker — the idiomatic BigQuery window-filter pattern, avoiding a subquery wrapper.

LEFT JOIN strategy (CTE 9) All joins from cleaned_demographics outward use LEFT JOIN so patients without biomarker data or complication records are retained in the cohort with NULLs. This preserves the full denominator for Kaplan-Meier censoring and prevents silent row loss.

Survival days clamping (CTE 3) GREATEST(0, LEAST(survival_days, 36500)) prevents negative values (caused by data entry errors where death precedes diagnosis in the synthetic data) and caps biologically impossible ages. The survival_days_flag column preserves the original quality signal for downstream filtering.

Child-Pugh alignment The 3-point biomarker scale and complication binary flags are a deliberate structural mirror of the validated Child-Pugh-Turcotte-Pugh (CTP) scoring system used in clinical hepatology. The composite score does not replicate CTP exactly (which also requires clinical ascites grading and encephalopathy grading beyond binary flags) but provides a reproducible, data-driven proxy score from EHR-available fields.


How to Run
-- Main output: full cohort with severity class

-- Execute the script as-is.

-- Supplementary A: survival summary by class (KM input)

-- Uncomment the block after the main SELECT.

-- Supplementary B: biomarker distribution per severity class

-- Uncomment the second supplementary block.

-- Supplementary C: complication co-occurrence matrix

-- Uncomment the third supplementary block.

Estimated bytes processed (approximate):

fhir_synthea.observation: ~103 GB (largest scan — filtered early by patient cohort subquery)
fhir_synthea.patient: ~1.7 GB
fhir_synthea.condition: ~varies

Cost optimisation note: If loading this cohort into your own dataset, materialise cirrhosis_patients as a table first, then use it as a filter rather than a subquery — this prevents the full observation table scan for non-cohort patients.


Insights This Query Enables
📉 Kaplan-Meier survival curves — stratified by Class A / B / C, gender, age group
🔬 Biomarker risk profile — distribution of Bilirubin, Albumin, PT across severity classes
🧮 Predictive feature matrix — all fields ready as input features for Cox PH or Random Survival Forest models
⚠️ Complication co-occurrence — frequency and survival impact of multi-complication patients
📊 Cohort demographic breakdown — age, gender, race, ethnicity across severity bands


Related Portfolio Work
Asset
Link
Companion Notebook
cirrhosis-survival-analysis-and-predictive-model.ipynb
UPF Metabolic Audit SQL
health-nutrition/upf_metabolic_analysis.sql
FitLife360 Wearables Audit
wearables-fitlife360/


