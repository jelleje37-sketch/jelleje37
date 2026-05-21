-- ============================================================
-- Script    : upf_metabolic_analysis.sql
-- Project   : Ultra-Processed Foods & Metabolism Audit
-- Author    : jelleje37
-- Dataset   : bigquery-public-data.fda_food
-- Tables    : food_events, food_enforcement
-- Last Upd  : 2026-05-20
-- Purpose   : Analyse FDA adverse event reports and Class I/II
--             enforcement actions linked to food product categories
--             most associated with ultra-processed food (UPF)
--             ingredients. Produces demographic risk profiles,
--             reaction severity tiers, and temporal trends for
--             portfolio notebook integration.
-- ============================================================


-- ============================================================
-- CTE 1: age_standardised_events
-- Normalise consumer age to years, filter to known demographics,
-- and assign age brackets for downstream cohort aggregation.
-- ============================================================
WITH age_standardised_events AS (
  SELECT
    report_number,
    date_started,
    date_created,
    products_brand_name,
    products_industry_name,
    products_industry_code,
    products_role,
    reactions,
    outcomes,

    -- Normalise age to years regardless of source unit
    CASE consumer_age_unit
      WHEN 'Year(s)'   THEN consumer_age
      WHEN 'Month(s)'  THEN ROUND(consumer_age / 12.0, 2)
      WHEN 'Week(s)'   THEN ROUND(consumer_age / 52.0, 2)
      WHEN 'Day(s)'    THEN ROUND(consumer_age / 365.0, 2)
      WHEN 'Decade(s)' THEN consumer_age * 10.0
      ELSE NULL
    END AS age_years,

    -- Standardise gender label
    CASE
      WHEN UPPER(consumer_gender) IN ('FEMALE', 'F') THEN 'Female'
      WHEN UPPER(consumer_gender) IN ('MALE',   'M') THEN 'Male'
      ELSE 'Unknown'
    END AS gender,

    -- Age bracket for cohort stratification
    CASE
      WHEN consumer_age IS NULL OR consumer_age_unit NOT IN ('Year(s)','Decade(s)') THEN 'Unknown'
      WHEN consumer_age < 18                                                         THEN 'Under 18'
      WHEN consumer_age BETWEEN 18  AND 34                                           THEN '18-34'
      WHEN consumer_age BETWEEN 35  AND 54                                           THEN '35-54'
      WHEN consumer_age BETWEEN 55  AND 64                                           THEN '55-64'
      WHEN consumer_age >= 65                                                        THEN '65+'
      ELSE 'Unknown'
    END AS age_group

  FROM `bigquery-public-data.fda_food.food_events`
  WHERE
    -- Keep only Food/Dietary-Supplement industry codes (exclude cosmetics)
    products_industry_code NOT IN ('53', '54', '55', '56', '57', '58', '59',
                                   '60', '61', '62', '63', '64', '65',
                                   '66', '67', '68', '69', '70')
    AND date_started IS NOT NULL
),


-- ============================================================
-- CTE 2: upf_flagged_events
-- Flag records that map to UPF-aligned industry categories
-- (processed snacks, sweetened beverages, diet supplements,
--  flavoured dairy, prepared meals, etc.)
-- ============================================================
upf_flagged_events AS (
  SELECT
    *,
    CASE
      WHEN REGEXP_CONTAINS(
             LOWER(products_industry_name),
             r'snack|chip|crisp|candy|confection|chocolate|cookie|cracker|'
             || r'cereal|granola|energy bar|protein bar|'
             || r'soda|soft drink|energy drink|sports drink|flavored water|'
             || r'dietary supplement|weight loss|meal replacement|'
             || r'frozen meal|ready.to.eat|instant|processed meat|'
             || r'flavored|flavoured|sweetened|artificial'
           )
      THEN TRUE
      ELSE FALSE
    END AS is_upf_category

  FROM age_standardised_events
),


-- ============================================================
-- CTE 3: severity_classified_events
-- Parse the free-text `outcomes` field into a 3-tier severity
-- score to enable ranked aggregation.
-- Tier 3 (Critical) → hospitalisation, death, disability
-- Tier 2 (Moderate) → ER visit, medical intervention
-- Tier 1 (Mild)     → non-serious / other
-- ============================================================
severity_classified_events AS (
  SELECT
    *,
    CASE
      WHEN REGEXP_CONTAINS(
             LOWER(outcomes),
             r'death|life.threatening|disab|hospitaliz|hospitalis|congenital'
           )
      THEN 3

      WHEN REGEXP_CONTAINS(
             LOWER(outcomes),
             r'emergency|er visit|medically important|visited emergency'
           )
      THEN 2

      ELSE 1
    END AS severity_tier,

    CASE
      WHEN REGEXP_CONTAINS(
             LOWER(outcomes),
             r'death|life.threatening|disab|hospitaliz|hospitalis|congenital'
           )
      THEN 'Critical'
      WHEN REGEXP_CONTAINS(
             LOWER(outcomes),
             r'emergency|er visit|medically important|visited emergency'
           )
      THEN 'Moderate'
      ELSE 'Mild / Other'
    END AS severity_label

  FROM upf_flagged_events
),


-- ============================================================
-- CTE 4: enforcement_class_i_ii
-- Pull Class I and II food recall actions — the highest
-- health-hazard tiers — for brand-level cross-referencing.
-- ============================================================
enforcement_class_i_ii AS (
  SELECT
    recall_number,
    recalling_firm,
    product_description,
    reason_for_recall,
    classification,
    recall_initiation_date,
    status,
    state,
    distribution_pattern,
    voluntary_mandated
  FROM `bigquery-public-data.fda_food.food_enforcement`
  WHERE
    classification IN ('Class I', 'Class II')
    AND product_type = 'Food'
    AND recall_initiation_date IS NOT NULL
),


-- ============================================================
-- CTE 5: demographic_risk_profile
-- Aggregate adverse events by demographic cohort and UPF flag.
-- Core output: who is most affected, and in which categories?
-- ============================================================
demographic_risk_profile AS (
  SELECT
    age_group,
    gender,
    is_upf_category,
    products_industry_name,
    severity_label,
    COUNT(*)                                   AS total_events,
    ROUND(AVG(age_years), 1)                   AS avg_age_years,
    COUNTIF(severity_tier = 3)                 AS critical_events,
    COUNTIF(severity_tier = 2)                 AS moderate_events,
    COUNTIF(severity_tier = 1)                 AS mild_events,
    ROUND(
      SAFE_DIVIDE(
        COUNTIF(severity_tier >= 2),
        COUNT(*)
      ) * 100, 2
    )                                          AS pct_moderate_or_critical,
    MIN(date_started)                          AS earliest_event,
    MAX(date_started)                          AS latest_event
  FROM severity_classified_events
  GROUP BY 1, 2, 3, 4, 5
),


-- ============================================================
-- CTE 6: top_reactions_by_category
-- Identify the most commonly reported metabolic and systemic
-- reactions per food industry category (UPF subset).
-- ============================================================
top_reactions_by_category AS (
  SELECT
    products_industry_name,
    reactions,
    COUNT(*) AS reaction_count,
    ROUND(
      SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER (PARTITION BY products_industry_name)) * 100, 2
    )        AS pct_within_category
  FROM severity_classified_events
  WHERE
    is_upf_category = TRUE
    AND reactions IS NOT NULL
  GROUP BY 1, 2
  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY products_industry_name
      ORDER BY reaction_count DESC
    ) <= 5   -- top 5 reactions per category
),


-- ============================================================
-- CTE 7: annual_trend
-- Year-over-year event volume for UPF-flagged categories,
-- split by severity — feeds time-series visualisation.
-- ============================================================
annual_trend AS (
  SELECT
    EXTRACT(YEAR FROM date_started) AS event_year,
    is_upf_category,
    severity_label,
    COUNT(*)                        AS event_count
  FROM severity_classified_events
  WHERE EXTRACT(YEAR FROM date_started) BETWEEN 2004 AND 2024
  GROUP BY 1, 2, 3
)


-- ============================================================
-- FINAL OUTPUT: Demographic risk profile for UPF categories
-- Change the FROM clause to reference any CTE above for
-- alternate analytical outputs:
--   → top_reactions_by_category  (reaction deep-dive)
--   → annual_trend               (time-series trend)
--   → enforcement_class_i_ii     (recall cross-reference)
-- ============================================================
SELECT
  age_group,
  gender,
  products_industry_name                    AS food_category,
  severity_label,
  total_events,
  critical_events,
  moderate_events,
  mild_events,
  pct_moderate_or_critical,
  avg_age_years,
  earliest_event,
  latest_event
FROM demographic_risk_profile
WHERE is_upf_category = TRUE
ORDER BY
  total_events          DESC,
  pct_moderate_or_critical DESC,
  age_group,
  gender;


-- ============================================================
-- SUPPLEMENTARY QUERY A: Top 5 reactions per UPF category
-- Uncomment to run independently.
-- ============================================================
/*
SELECT
  products_industry_name  AS food_category,
  reactions,
  reaction_count,
  pct_within_category
FROM top_reactions_by_category
ORDER BY products_industry_name, reaction_count DESC;
*/


-- ============================================================
-- SUPPLEMENTARY QUERY B: Annual UPF adverse event trend
-- Uncomment to run independently.
-- ============================================================
/*
SELECT
  event_year,
  is_upf_category,
  severity_label,
  event_count
FROM annual_trend
ORDER BY event_year, severity_label;
*/


-- ============================================================
-- SUPPLEMENTARY QUERY C: Class I/II enforcement recall list
-- Uncomment to run independently.
-- ============================================================
/*
SELECT
  recall_number,
  recalling_firm,
  classification,
  reason_for_recall,
  recall_initiation_date,
  status,
  state
FROM enforcement_class_i_ii
ORDER BY recall_initiation_date DESC
LIMIT 100;
*/
