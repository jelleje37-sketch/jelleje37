-- ============================================================================
-- Project: Cirrhosis Survival Cohort Engineering Pipeline
-- Domain: Clinical Data Analytics / Hepatology Informatics
-- Dataset: BigQuery Public Data - fhir_synthea
-- Dialect: BigQuery Standard SQL (GoogleSQL)
-- Target Asset: clinical-data/cirrhosis_survival_cohort.sql
-- ============================================================================

WITH cirrhosis_patients AS (
  -- CTE 1: Filter confirmed cirrhosis patients via ICD-10 codes and locate T0 (onset)
  SELECT 
    c.subject.patientId AS patient_id,
    MIN(SAFE_CAST(LEFT(c.onset.dateTime, 10) AS DATE)) AS t0_diagnosis_date
  FROM 
    `bigquery-public-data.fhir_synthea.condition` AS c
  CROSS JOIN 
    UNNEST(c.code.coding) AS cond_coding
  WHERE 
    cond_coding.system = 'http://hl7.org/fhir/sid/icd-10'
    AND REGEXP_CONTAINS(cond_coding.code, r'^K74\.[0-6]')
    AND c.verificationStatus = 'confirmed'
  GROUP BY 
    patient_id
),

patient_demographics AS (
  -- CTE 2: Join patient core fields and compute raw survival metrics
  SELECT 
    cp.patient_id,
    cp.t0_diagnosis_date,
    p.gender,
    p.us_core_race.text.value.string AS race,
    p.us_core_ethnicity.text.value.string AS ethnicity,
    SAFE_CAST(p.birthDate AS DATE) AS birth_date,
    p.deceased.boolean AS is_deceased,
    SAFE_CAST(LEFT(p.deceased.dateTime, 10) AS DATE) AS death_date,
    CAST(p.meta.lastUpdated AS DATE) AS last_updated_date,
    -- Time-to-event calculation variables
    DATE_DIFF(cp.t0_diagnosis_date, SAFE_CAST(p.birthDate AS DATE), YEAR) AS age_at_diagnosis,
    CASE 
      WHEN p.deceased.boolean = TRUE THEN DATE_DIFF(SAFE_CAST(LEFT(p.deceased.dateTime, 10) AS DATE), cp.t0_diagnosis_date, DAY)
      ELSE DATE_DIFF(CAST(p.meta.lastUpdated AS DATE), cp.t0_diagnosis_date, DAY)
    END AS survival_days_raw
  FROM 
    cirrhosis_patients AS cp
  INNER JOIN 
    `bigquery-public-data.fhir_synthea.patient` AS p ON cp.patient_id = p.id
),

cleaned_demographics AS (
  -- CTE 3: Clamp survival days, handle data quality anomalies, and build age bands
  SELECT 
    pd.*,
    GREATEST(0, LEAST(pd.survival_days_raw, 36500)) AS survival_days,
    CASE 
      WHEN pd.survival_days_raw < 0 THEN 'Error: Death Precedes Diagnosis'
      WHEN pd.survival_days_raw > 36500 THEN 'Warning: Exceeds 100 Years'
      ELSE 'Clean'
    END AS survival_days_flag,
    CASE 
      WHEN pd.age_at_diagnosis < 18 THEN 'Pediatric'
      WHEN pd.age_at_diagnosis BETWEEN 18 AND 34 THEN '18-34'
      WHEN pd.age_at_diagnosis BETWEEN 35 AND 49 THEN '35-49'
      WHEN pd.age_at_diagnosis BETWEEN 50 AND 64 THEN '50-64'
      ELSE '65+'
    END AS age_group
  FROM 
    patient_demographics AS pd
),

biomarker_observations_raw AS (
  -- CTE 4: Unnest and isolate specific LOINC lab results for our active cohort denominator
  SELECT 
    cd.patient_id,
    obs_coding.code AS loinc_code,
    obs.value.quantity.value AS lab_value,
    SAFE_CAST(LEFT(obs.effective.dateTime, 10) AS DATE) AS observation_date
  FROM 
    cleaned_demographics AS cd
  INNER JOIN 
    `bigquery-public-data.fhir_synthea.observation` AS obs ON cd.patient_id = obs.subject.patientId
  CROSS JOIN 
    UNNEST(obs.code.coding) AS obs_coding
  WHERE 
    obs_coding.system = 'http://loinc.org'
    AND obs_coding.code IN ('1975-2', '1751-7', '5902-2')
    AND obs.status IN ('final', 'amended', 'corrected')
    -- Focus purely on observations recorded at or after the clinical T0 timeline
    AND SAFE_CAST(LEFT(obs.effective.dateTime, 10) AS DATE) >= cd.t0_diagnosis_date
),

biomarker_most_recent AS (
  -- CTE 5: Window function deduplication to grab the latest lab per metric per client
  SELECT 
    bor.*
  FROM 
    biomarker_observations_raw AS bor
  QUALIFY ROW_NUMBER() OVER(
    PARTITION BY bor.patient_id, bor.loinc_code 
    ORDER BY bor.observation_date DESC, bor.lab_value DESC
  ) = 1
),

biomarkers_pivoted AS (
  -- CTE 6: Pivot long schema to wide clinical profile records
  SELECT 
    bmr.patient_id,
    MAX(CASE WHEN bmr.loinc_code = '1975-2' THEN bmr.lab_value END) AS total_bilirubin,
    MAX(CASE WHEN bmr.loinc_code = '1751-7' THEN bmr.lab_value END) AS serum_albumin,
    MAX(CASE WHEN bmr.loinc_code = '5902-2' THEN bmr.lab_value END) AS prothrombin_time
  FROM 
    biomarker_most_recent AS bmr
  GROUP BY 
    bmr.patient_id
),

biomarker_risk_tiers AS (
  -- CTE 7: Apply verified Child-Pugh stratification criteria and score weightings
  SELECT 
    bp.patient_id,
    bp.total_bilirubin,
    bp.serum_albumin,
    bp.prothrombin_time,
    -- Bilirubin scoring
    CASE 
      WHEN bp.total_bilirubin < 2.0 THEN 1
      WHEN bp.total_bilirubin BETWEEN 2.0 AND 3.0 THEN 2
      WHEN bp.total_bilirubin > 3.0 THEN 3
      ELSE NULL 
    END AS cp_points_bilirubin,
    -- Albumin scoring (Inverted scale)
    CASE 
      WHEN bp.serum_albumin >= 3.5 THEN 1
      WHEN bp.serum_albumin BETWEEN 2.8 AND 3.4 THEN 2
      WHEN bp.serum_albumin < 2.8 THEN 3
      ELSE NULL 
    END AS cp_points_albumin,
    -- Prothrombin Time scoring
    CASE 
      WHEN bp.prothrombin_time < 14.0 THEN 1
      WHEN bp.prothrombin_time BETWEEN 14.0 AND 17.0 THEN 2
      WHEN bp.prothrombin_time > 17.0 THEN 3
      ELSE NULL 
    END AS cp_points_prothrombin
  FROM 
    biomarkers_pivoted AS bp
),

complication_flags AS (
  -- CTE 8: Aggregate secondary clinical complications utilizing SNOMED CT lookups
  SELECT 
    cd.patient_id,
    MAX(CASE WHEN cond_coding.code = '389026000' THEN 1 ELSE 0 END) AS has_ascites,
    MAX(CASE WHEN cond_coding.code = '13920009' THEN 1 ELSE 0 END) AS has_encephalopathy,
    MAX(CASE WHEN cond_coding.code = '28670008' THEN 1 ELSE 0 END) AS has_varices
  FROM 
    cleaned_demographics AS cd
  LEFT JOIN 
    `bigquery-public-data.fhir_synthea.condition` AS c ON cd.patient_id = c.subject.patientId
  CROSS JOIN 
    UNNEST(c.code.coding) AS cond_coding
  WHERE 
    cond_coding.system = 'http://snomed.info/sct'
    AND cond_coding.code IN ('389026000', '13920009', '28670008')
    AND c.verificationStatus = 'confirmed'
  GROUP BY 
    cd.patient_id
),

severity_scored_cohort AS (
  -- CTE 9: Full cohort unification, baseline matrix synthesis, and grading allocation
  SELECT 
    cd.patient_id,
    cd.gender,
    cd.race,
    cd.ethnicity,
    cd.age_at_diagnosis,
    cd.age_group,
    cd.t0_diagnosis_date,
    cd.survival_days,
    cd.survival_days_flag,
    cd.is_deceased,
    COALESCE(brt.total_bilirubin, NULL) AS latest_bilirubin,
    COALESCE(brt.serum_albumin, NULL) AS latest_albumin,
    COALESCE(brt.prothrombin_time, NULL) AS latest_prothrombin_time,
    COALESCE(cf.has_ascites, 0) AS has_ascites,
    COALESCE(cf.has_encephalopathy, 0) AS has_encephalopathy,
    COALESCE(cf.has_varices, 0) AS has_varices,
    -- Calculate complete proxy score if lab profile is present
    CASE 
      WHEN brt.cp_points_bilirubin IS NOT NULL 
           AND brt.cp_points_albumin IS NOT NULL 
           AND brt.cp_points_prothrombin IS NOT NULL THEN
           (brt.cp_points_bilirubin + brt.cp_points_albumin + brt.cp_points_prothrombin +
            COALESCE(cf.has_ascites, 0) + COALESCE(cf.has_encephalopathy, 0) + COALESCE(cf.has_varices, 0))
      ELSE NULL 
    END AS composite_severity_score
  FROM 
    cleaned_demographics AS cd
  LEFT JOIN 
    biomarker_risk_tiers AS brt USING (patient_id)
  LEFT JOIN 
    complication_flags AS cf USING (patient_id)
)

-- Primary Output Pipeline Generation
SELECT 
  ssc.*,
  CASE 
    WHEN ssc.composite_severity_score BETWEEN 3 AND 5 THEN 'Class A (Low Risk)'
    WHEN ssc.composite_severity_score BETWEEN 6 AND 9 THEN 'Class B (Moderate Risk)'
    WHEN ssc.composite_severity_score BETWEEN 10 AND 12 THEN 'Class C (High Risk)'
    ELSE 'Unscored (Incomplete Lab Panel)'
  END AS severity_class
FROM 
  severity_scored_cohort AS ssc;


-- ============================================================================
-- SUPPLEMENTARY QUERY A: Kaplan-Meier Survival Curve Aggregations
-- ============================================================================
-- SELECT 
--   CASE 
--     WHEN composite_severity_score BETWEEN 3 AND 5 THEN 'Class A'
--     WHEN composite_severity_score BETWEEN 6 AND 9 THEN 'Class B'
--     WHEN composite_severity_score BETWEEN 10 AND 12 THEN 'Class C'
--     ELSE 'Unscored'
--   END AS severity_class,
--   is_deceased,
--   ROUND(AVG(survival_days), 1) AS mean_survival_days,
--   COUNT(DISTINCT patient_id) AS total_patients
-- FROM severity_scored_cohort
-- GROUP BY 1, 2
-- ORDER BY 1, 2;
