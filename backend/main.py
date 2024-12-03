# from src.data_processing.drunkness_classifier import classify_drunkness
# from src.data_processing.plots import plot_combined_results
# from src.video.live_capture import capture_live_video_with_face_mesh
# from src.data_processing.rppg_chrome import extract_rppg_chrome
# from backend.src.config.settings import FPS, TIME_WINDOW_SEC
#
#
# def main():
#     """
#     Main function to run rPPG signal extraction and HR/HRV estimation.
#     """
#     print(f"Starting live video capture with a {TIME_WINDOW_SEC}-second window. Press 'q' to quit.")
#
#     # Capture and process video
#     rppg_signal, timestamps, hr_values, hrv_values, eye_redness_values = capture_live_video_with_face_mesh(
#         fps=FPS,
#         time_window_sec=TIME_WINDOW_SEC,
#         rppg_extraction_method=extract_rppg_chrome
#     )
#
#     # Classify drunkenness levels
#     drunk_levels = [
#         classify_drunkness(hr, hrv, eye_redness)
#         for hr, hrv, eye_redness in zip(hr_values, hrv_values, eye_redness_values)
#     ]
#
#     # Plot combined results
#     plot_combined_results(timestamps, rppg_signal, hr_values, hrv_values, drunk_levels, TIME_WINDOW_SEC)
#
#     print("Processing complete. Closing application.")
#
#
# if __name__ == "__main__":
#     main()


import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

from src.video.live_capture import process_frame

app = FastAPI()


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
