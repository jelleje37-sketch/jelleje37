# Data Cleaning SQL Template

## Purpose
This script standardizes and cleans raw data for analysis.

## Key Transformations
- Remove duplicates
- Handle missing values
- Standardize data types
- Create calculated fields

## Example Structure

```sql
-- Step 1: Identify duplicates
SELECT 
  column_name,
  COUNT(*) as duplicate_count
FROM raw_data
GROUP BY column_name
HAVING COUNT(*) > 1;

-- Step 2: Remove nulls and standardize
WITH cleaned_data AS (
  SELECT 
    column1,
    column2,
    CAST(column3 AS DATE) as date_column,
    UPPER(category_column) as category
  FROM raw_data
  WHERE column1 IS NOT NULL
)
SELECT * FROM cleaned_data;
```

## Next Steps
1. Load raw data into your database
2. Adapt this template to your dataset structure
3. Run cleaning transformations
4. Validate results
5. Export cleaned data for analysis
