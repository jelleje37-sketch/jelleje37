import pandas as pd
import sqlite3

def run_audit(file_path):
    """
    Run a data quality audit on wellness metrics CSV file.
    
    Args:
        file_path (str): Path to the CSV file containing wellness data
        
    Returns:
        None: Prints audit results to console
    """
    # Load the dataset
    df = pd.read_csv(file_path)
    
    # Quick data quality check
    print("--- Dataset Overview ---")
    print(df.info())
    print("\n--- Missing Values ---")
    print(df.isnull().sum())
    
    # Calculate initial summary for metabolic markers
    if 'metabolic_rate' in df.columns:
        print(f"\nAverage Metabolic Rate: {df['metabolic_rate'].mean():.2f}")
    
    # Additional wellness metrics summary
    if 'daily_steps' in df.columns:
        print(f"Average Daily Steps: {df['daily_steps'].mean():.0f}")
    
    if 'sleep_score' in df.columns:
        print(f"Average Sleep Score: {df['sleep_score'].mean():.2f}")
    
    if 'processed_food_intake_pct' in df.columns:
        print(f"Average UPF Intake (%): {df['processed_food_intake_pct'].mean():.2f}")


def load_to_database(csv_file, db_path='wellness.db', table_name='wellness_metrics'):
    """
    Load CSV data into SQLite database.
    
    Args:
        csv_file (str): Path to CSV file
        db_path (str): Path to SQLite database (default: wellness.db)
        table_name (str): Table name to insert data (default: wellness_metrics)
    """
    df = pd.read_csv(csv_file)
    conn = sqlite3.connect(db_path)
    df.to_sql(table_name, conn, if_exists='append', index=False)
    conn.close()
    print(f"✓ Loaded {len(df)} records to {table_name} table")


# Placeholder for your future dataset path
# run_audit('wellness_data.csv')
# load_to_database('wellness_data.csv')
"Move audit script to project folder"
