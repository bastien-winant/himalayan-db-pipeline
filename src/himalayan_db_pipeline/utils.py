from dbfread import DBF
import pandas as pd
import numpy as np
from pathlib import Path

def read_dbf(file_path: Path | str) -> pd.DataFrame:
  dbf = DBF(file_path)
  df = pd.DataFrame(iter(dbf))

  df = (
    df.replace(r'^\s*$', np.nan, regex=True)
      .dropna(axis=0, how="all")
      .dropna(axis=1, how="all")
      .drop_duplicates()
      .reset_index(drop=True)
  )

  df.columns = map(lambda x: x.lower(), df.columns)

  return df