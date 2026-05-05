import pandas as pd
import numpy as np
from typing import Tuple, Dict, Any


def load_data(file_path: str) -> pd.DataFrame:
    """
    Load data from various file formats.
    
    Parameters:
    -----------
    file_path : str
        Path to the data file (CSV, Excel, etc.)
    
    Returns:
    --------
    pd.DataFrame
        Loaded dataframe
    """
    if file_path.endswith('.csv'):
        return pd.read_csv(file_path)
    elif file_path.endswith(('.xlsx', '.xls')):
        return pd.read_excel(file_path)
    else:
        raise ValueError(f"Unsupported file format: {file_path}")


def validate_data_schema(df: pd.DataFrame, required_columns: list) -> Tuple[bool, list]:
    """
    Validate that dataframe contains all required columns.
    
    Parameters:
    -----------
    df : pd.DataFrame
        Data frame to validate
    required_columns : list
        List of required column names
    
    Returns:
    --------
    Tuple[bool, list]
        Validation status and list of missing columns
    """
    missing_columns = [col for col in required_columns if col not in df.columns]
    return len(missing_columns) == 0, missing_columns


def check_missing_values(df: pd.DataFrame) -> Dict[str, int]:
    """
    Check for missing values in the dataframe.
    
    Parameters:
    -----------
    df : pd.DataFrame
        Data frame to check
    
    Returns:
    --------
    Dict[str, int]
        Dictionary with column names and their missing value counts
    """
    return df.isnull().sum().to_dict()


def check_data_types(df: pd.DataFrame, expected_types: Dict[str, str]) -> Dict[str, Any]:
    """
    Validate data types of columns.
    
    Parameters:
    -----------
    df : pd.DataFrame
        Data frame to check
    expected_types : Dict[str, str]
        Dictionary mapping column names to expected data types
    
    Returns:
    --------
    Dict[str, Any]
        Validation results for each column
    """
    type_check = {}
    for col, expected_type in expected_types.items():
        if col in df.columns:
            actual_type = str(df[col].dtype)
            type_check[col] = {
                'expected': expected_type,
                'actual': actual_type,
                'matches': expected_type.lower() in actual_type.lower()
            }
    return type_check


def prepare_for_ingestion(df: pd.DataFrame) -> pd.DataFrame:
    """
    Prepare data for ingestion into the wellness metrics database.
    
    Parameters:
    -----------
    df : pd.DataFrame
        Raw data frame
    
    Returns:
    --------
    pd.DataFrame
        Cleaned and prepared data frame
    """
    # Remove duplicate rows
    df = df.drop_duplicates()
    
    # Reset index
    df = df.reset_index(drop=True)
    
    # Convert column names to lowercase and replace spaces with underscores
    df.columns = df.columns.str.lower().str.replace(' ', '_')
    
    return df


if __name__ == "__main__":
    print("FitLife360 Data Check Module")
    print("=" * 50)
    print("Ready to validate and prepare wellness metrics data.")
