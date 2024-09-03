from fastapi import FastAPI
from loguru import logger
from transcriber.utils import delete_file, download_file, whisper_transcribe
import traceback

app = FastAPI()

@app.get("/transcribe")
def transcribe(s3_file_key: str, file_path_is_local=False) -> dict:
    logger.info(f"Transcribing file={s3_file_key}")

    download_path = s3_file_key
    try:
        if not file_path_is_local:
            download_path = download_file(s3_file_key)

        result = whisper_transcribe(download_path)
        logger.success("Transcribed correctly")
    
        delete_file(download_path)

        return {
            "language": result["language"],
            "text": repr(result["text"])
        }
    except KeyboardInterrupt:
        raise
    except Exception as e:
        logger.error(e)
        return {
            "error": repr(e),
            "trace": traceback.format_exc()
        }
