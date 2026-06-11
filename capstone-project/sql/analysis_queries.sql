# Analysis Queries Template

## Purpose
Core SQL queries for exploratory analysis and insight generation.

## Template Queries

### Query 1: Demographic Summary
```sql
SELECT 
  demographic_column,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage,
  ROUND(AVG(metric_column), 2) as avg_metric
FROM data
GROUP BY demographic_column
ORDER BY count DESC;
```

### Query 2: Trend Analysis
```sql
SELECT 
  DATE_TRUNC(date_column, MONTH) as month,
  COUNT(*) as event_count,
  ROUND(AVG(outcome_metric), 2) as avg_outcome
FROM data
GROUP BY DATE_TRUNC(date_column, MONTH)
ORDER BY month;
```

### Query 3: Correlation Analysis
```sql
SELECT 
  category_column,
  ROUND(CORR(variable1, variable2), 3) as correlation,
  COUNT(*) as sample_size
FROM data
WHERE variable1 IS NOT NULL AND variable2 IS NOT NULL
GROUP BY category_column;
```

### Query 4: Risk Stratification
```sql
SELECT 
  risk_level,
  COUNT(*) as patient_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total,
  ROUND(AVG(outcome), 2) as avg_outcome_rate
FROM data
GROUP BY risk_level
ORDER BY avg_outcome_rate DESC;
```

## Key Metrics to Track
- Sample size
- Distributions
- Correlations
- Trends over time
- Risk indicators

## Next Steps
1. Customize queries for your dataset
2. Document findings from each query
3. Create supporting visualizations
4. Present insights to stakeholders
