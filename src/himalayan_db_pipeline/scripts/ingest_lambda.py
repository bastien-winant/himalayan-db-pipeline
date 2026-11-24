import logging
from pathlib import Path
import requests
from zipfile import ZipFile
from dbfread import DBF
import pandas as pd
import numpy as np
import boto3
from shutil import rmtree
from os import remove

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

tmp_path = Path("/tmp")
zip_path = tmp_path / "himalayan_db.zip"
raw_files_dir = tmp_path / "Himalayan Database" / "HIMDATA"
parquet_files_dir = tmp_path / "parquet"

data_file_names = ["peaks", "members", "exped"]

bucket_name = "himalayan-db-data-779518747346-eu-central-1-an"

def fetch_zip_file(url: str, file_path: Path | str) -> None:
  """Fetches a ZIP file via HTTP and saves it at the given path."""
  headers = {
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36"
  }

  response = requests.get(url, headers=headers, stream=True)
  response.raise_for_status()

  with open(file_path, "wb") as f:
    for chunk in response.iter_content(chunk_size=8192):
      f.write(chunk)


def extract_files(file_path: Path | str, target_dir: Path | str) -> list[Path | str]:
  """Extracts all contents from the input compressed file and saves them in the input directory."""
  file_path = Path(file_path)
  target_dir = Path(target_dir)

  if not file_path.exists():
    raise Exception(f"File '{file_path}' does not exist.")

  if not file_path.is_file():
    raise Exception(f"Path '{file_path}' is not a file.")

  # create the target path if doesn't exist
  target_dir.mkdir(parents=True, exist_ok=True)

  with ZipFile(file_path, "r") as f:
    f.extractall(target_dir)
  
  return [file for file in raw_files_dir.iterdir() if file.is_file()]


def read_dbf(dbf_file: Path | str) -> pd.DataFrame:
  """Reads the contents of the input DBF file into a Pandas DataFrame."""
  # read the DBF data into a Pandas df
  dbf = DBF(dbf_file)
  df = pd.DataFrame(iter(dbf))

  return df


def convert_dfb_to_parquet(files: list[Path | str], target_dir):
  """Converts all DBF files in the source directory to Parquet and saves them in the target directory."""
  target_dir = Path(target_dir)
  target_dir.mkdir(exist_ok=True, parents=True)

  pq_files = []

  for file in files:
    if file.suffix == ".DBF":
      df = read_dbf(file.absolute())
      parquet_filename = file.with_suffix(".parquet").name
      df.to_parquet(target_dir / parquet_filename, index=False)
      pq_files.append(target_dir / parquet_filename)
  
  return pq_files


def upload_to_s3(
    files: list[Path | str], bucket_name: str, bucket_folder: str = ""):
  for file in files:
    s3_object = f"{bucket_folder}/{file.name}"
    s3.upload_file(file.absolute(), bucket_name, s3_object)


def lambda_handler(event, context):
  url = "https://www.himalayandatabase.com/downloads/Himalayan%20Database.zip"

  try:
    fetch_zip_file(url=url, file_path=zip_path)
    raw_files = extract_files(file_path=zip_path, target_dir=tmp_path)
    data_files = [file for file in raw_files if file.suffix in [".FPT", ".DBF"] and file.stem in data_file_names]
    parquet_files = convert_dfb_to_parquet(files=data_files, target_dir=parquet_files_dir)

    upload_to_s3(
      files=data_files,
      bucket_name=bucket_name,
      bucket_folder="stg/dbf"
    )

    upload_to_s3(
      files=parquet_files,
      bucket_name=bucket_name,
      bucket_folder="stg/parquet"
    )

    rmtree(raw_files_dir)
    rmtree(parquet_files_dir)
    remove(zip_path)
  except Exception as e:
    logger.exception("message")
    raise e