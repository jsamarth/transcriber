import whisper
import boto3
from loguru import logger
import os

model = whisper.load_model("base")
s3 = boto3.client('s3')
_S3_AUDIO_BUCKET_NAME = "samarth-transcriber-audio-files"

def download_file(key, bucket_name=_S3_AUDIO_BUCKET_NAME):
    download_path = f'{key}'

    s3.download_file(bucket_name, key, download_path)
    logger.info(f"File successfully downloaded to {download_path}")

    return download_path

def delete_file(file_path):
    try:
        os.remove(file_path)
        logger.info(f"File {file_path} deleted successfully.")
    except FileNotFoundError:
        logger.info(f"File {file_path} not found.")
    except PermissionError:
        logger.info(f"Permission denied: Unable to delete {file_path}.")
    except Exception as e:
        logger.info(f"An error occurred while deleting the file: {e}")

def whisper_transcribe(file_path):
    return model.transcribe(file_path)
