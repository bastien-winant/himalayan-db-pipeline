from dbfread import DBF
import pandas as pd
import numpy as np
from pathlib import Path

def read_dbf(file_path: Path | str) -> pd.DataFrame:
  dbf = DBF(file_path)
  df = pd.DataFrame(iter(dbf))

  return df