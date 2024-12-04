import base64
import logging

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from backend.src.video.live_capture import handle_frame, process_frames

app = FastAPI()

frame_buffer = []  # Buffer to store frames for 10 seconds
# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")


@app.get("/")
def health_check():
    """
    Health check for the backend.
    """
    return {"status": "OK", "message": "Backend is running!"}


@app.post("/process_batch/")
async def process_batch(request: Request):
    global frame_buffer

    try:
        # Parse JSON data
        data = await request.json()

        # Log receipt of batch
        logging.info(f"Received batch with {len(data['frames'])} frames.")

        # Retrieve and decode frames
        for frame in data['frames']:
            y_plane = base64.b64decode(frame['y_plane'])
            u_plane = base64.b64decode(frame['u_plane'])
            v_plane = base64.b64decode(frame['v_plane'])
            width = int(frame['width'])
            height = int(frame['height'])

            # Process the frame into RGB format
            rgb_frame = handle_frame(width, height, y_plane, u_plane, v_plane)

            if rgb_frame is not None:
                frame_buffer.append(rgb_frame)

        # Process if 300 frames (10 batches) are received
        if len(frame_buffer) >= 300:
            logging.info("Processing 300 frames for HR, HRV, and redness estimation...")
            results = process_frames(frame_buffer)
            frame_buffer.clear()  # Clear buffer after processing

            # Log and return results
            logging.info(f"Processed batch results: {results}")
            return JSONResponse(content=results)

        # If not enough frames, respond with a waiting message
        return JSONResponse(content={"status": "Waiting for more frames"})

    except Exception as e:
        logging.error(f"Error processing batch: {e}")
        return JSONResponse(content={"error": str(e)})
