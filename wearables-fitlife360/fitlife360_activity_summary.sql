-- ============================================================================
-- Project: FitLife360 Regional Performance & Metabolic Benchmarking Engine
-- Domain: Consumer Health-Tech / Population Behavioral Analytics
-- Dataset: BigQuery Public Data - america_health_rankings
-- Dialect: BigQuery Standard SQL (GoogleSQL)
-- Target Asset: wearables-fitlife360/fitlife360_activity_summary.sql
-- ============================================================================

WITH raw_behavioral_metrics AS (
  -- CTE 1: Isolate lifestyle and behavioral risk vectors across populations
  SELECT 
    state_name,
    year,
    race_ethnicity AS subpopulation,
    value_name AS metric_name,
    value AS metric_value
  FROM 
    `bigquery-public-data.america_health_rankings.ahr`
  WHERE 
    value_name IN ('Physical Inactivity', 'Insufficient Sleep', 'Exercise')
    AND value IS NOT NULL
),

raw_outcome_metrics AS (
  -- CTE 2: Isolate metabolic and cardiovascular outcomes
  SELECT 
    state_name,
    year,
    race_ethnicity AS subpopulation,
    value_name AS metric_name,
    value AS metric_value
  FROM 
    `bigquery-public-data.america_health_rankings.ahr`
  WHERE 
    value_name IN ('Obesity', 'Diabetes', 'High Blood Pressure')
    AND value IS NOT NULL
),

behavior_pivoted AS (
  -- CTE 3: Pivot long tracking records into structural behavioral profiles
  SELECT 
    state_name,
    year,
    subpopulation,
    ROUND(MAX(CASE WHEN metric_name = 'Physical Inactivity' THEN metric_value END), 2) AS pct_sedentary,
    ROUND(MAX(CASE WHEN metric_name = 'Insufficient Sleep' THEN metric_value END), 2) AS pct_sleep_deprived,
    ROUND(MAX(CASE WHEN metric_name = 'Exercise' THEN metric_value END), 2) AS pct_active_exercise
  FROM 
    raw_behavioral_metrics
  GROUP BY 
    state_name, year, subpopulation
),

outcomes_pivoted AS (
  -- CTE 4: Pivot long records into structural physiological profiles
  SELECT 
    state_name,
    year,
    subpopulation,
    ROUND(MAX(CASE WHEN metric_name = 'Obesity' THEN metric_value END), 2) AS pct_obesity,
    ROUND(MAX(CASE WHEN metric_name = 'Diabetes' THEN metric_value END), 2) AS pct_diabetes,
    ROUND(MAX(CASE WHEN metric_name = 'High Blood Pressure' THEN metric_value END), 2) AS pct_hypertension
  FROM 
    raw_outcome_metrics
  GROUP BY 
    state_name, year, subpopulation
),

unified_regional_benchmarks AS (
  -- CTE 5: Combine behavior matrices with physical health outcomes
  SELECT 
    bp.state_name,
    bp.year,
    bp.subpopulation,
    bp.pct_sedentary,
    bp.pct_sleep_deprived,
    COALESCE(bp.pct_active_exercise, 0.0) AS pct_active_exercise,
    op.pct_obesity,
    op.pct_diabetes,
    op.pct_hypertension
  FROM 
    behavior_pivoted AS bp
  INNER JOIN 
    outcomes_pivoted AS op 
    ON bp.state_name = op.state_name 
    AND bp.year = op.year 
    AND bp.subpopulation = op.subpopulation
)

-- Final SELECT: Compute custom composite platform indicators and performance categories
SELECT 
  urb.*,
  -- FitLife360 Proprietary Metrics Formulation
  ROUND((urb.pct_sedentary + urb.pct_sleep_deprived) / 2.0, 2) AS behavioral_risk_index,
  ROUND((urb.pct_obesity + urb.pct_diabetes + urb.pct_hypertension) / 3.0, 2) AS metabolic_deficit_score,
  
  -- Algorithmic Stratification of State Health Environments
  CASE 
    WHEN urb.pct_sedentary < 20.0 AND urb.pct_obesity < 25.0 THEN 'Tier 1: Optimal Recovery Environment'
    WHEN urb.pct_sedentary BETWEEN 20.0 AND 30.0 THEN 'Tier 2: Moderate Behavioral Headwinds'
    ELSE 'Tier 3: Critical Metabolic Risk Zone'
  END AS regional_benchmark_tier
FROM 
  unified_regional_benchmarks AS urb
ORDER BY 
  year DESC, 
  metabolic_deficit_score DESC;
