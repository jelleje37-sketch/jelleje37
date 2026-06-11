# Feature Engineering SQL Template

## Purpose
Create new analytical features from raw data.

## Common Feature Engineering Techniques

### 1. Age Binning
```sql
SELECT 
  age,
  CASE 
    WHEN age < 18 THEN '0-17'
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 50 THEN '31-50'
    WHEN age > 50 THEN '50+'
  END as age_group
FROM data;
```

### 2. Risk Classification
```sql
SELECT 
  biomarker_value,
  CASE 
    WHEN biomarker_value > 90 THEN 'High Risk'
    WHEN biomarker_value BETWEEN 70 AND 90 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END as risk_level
FROM data;
```

### 3. Trend Calculation
```sql
SELECT 
  date_column,
  metric_value,
  LAG(metric_value) OVER (ORDER BY date_column) as previous_value,
  metric_value - LAG(metric_value) OVER (ORDER BY date_column) as value_change
FROM data;
```

## Next Steps
1. Identify business logic for new features
2. Build and test feature creation queries
3. Validate feature distributions
4. Document feature definitions
5. Integrate into analysis pipeline