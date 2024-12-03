import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

from backend.src.video.live_capture import process_frame

app = FastAPI()


@app.get("/")
def health_check():
    """
    Health check for the backend.
    """
    return {"status": "OK", "message": "Backend is running!"}

@app.post("/process_frame/")
async def process_frame_endpoint(frame: UploadFile = File(...)):
    """
    Receive a single frame from the frontend, process it, and return results.
    """
    contents = await frame.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Process the frame (modify `process_frame` in live_capture)
    results = process_frame(img)

    return JSONResponse(results)
