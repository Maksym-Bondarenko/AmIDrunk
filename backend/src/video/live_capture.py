import logging
import time

import cv2
import mediapipe as mp
import numpy as np

from backend.src.data_processing.drunkness_classifier import classify_drunkness
from backend.src.data_processing.eye_redness import extract_eye_redness
from backend.src.data_processing.metrics import compute_metrics
from backend.src.utils import bandpass_filter

# Mediapipe initialization
mp_face_mesh = mp.solutions.face_mesh

# Buffers for rPPG signal and timestamps
rppg_signal_buffer = []
timestamps_buffer = []
fps = 30  # Frames per second


def handle_frame(width, height, y_plane, u_plane, v_plane):
    """
    Decodes YUV planes into an RGB image and returns it.

    :param width: Frame width.
    :param height: Frame height.
    :param y_plane: Y-plane data.
    :param u_plane: U-plane data.
    :param v_plane: V-plane data.
    :return: Decoded RGB frame (numpy array).
    """
    try:
        # Decode YUV planes
        y = np.frombuffer(y_plane, dtype=np.uint8).reshape((height, width))
        u = np.frombuffer(u_plane, dtype=np.uint8).reshape((height // 2, width // 2))
        v = np.frombuffer(v_plane, dtype=np.uint8).reshape((height // 2, width // 2))

        # Resize U and V planes to match Y plane size
        u_resized = cv2.resize(u, (width, height), interpolation=cv2.INTER_LINEAR)
        v_resized = cv2.resize(v, (width, height), interpolation=cv2.INTER_LINEAR)

        # Combine YUV planes into a single image
        yuv_image = np.dstack((y, u_resized, v_resized))

        # Convert YUV to RGB
        rgb_image = cv2.cvtColor(yuv_image, cv2.COLOR_YUV2RGB)
        return rgb_image
    except Exception as e:
        print(f"[ERROR] Failed to decode YUV planes: {e}")
        return None


def process_frames(frames):
    """
    Process accumulated frames and return HR, HRV, and eye redness.
    """
    try:
        global rppg_signal_buffer, timestamps_buffer

        # Initialize Mediapipe Face Mesh
        with mp_face_mesh.FaceMesh(static_image_mode=False, max_num_faces=1, refine_landmarks=True) as face_mesh:
            for frame in frames:
                # Process frame
                results = face_mesh.process(frame)
                if results.multi_face_landmarks:
                    face_landmarks = results.multi_face_landmarks[0]
                    ih, iw, _ = frame.shape

                    # Define forehead region for rPPG extraction
                    forehead_indices = [10, 338, 297, 332, 284]
                    forehead_points = np.array(
                        [[int(face_landmarks.landmark[idx].x * iw), int(face_landmarks.landmark[idx].y * ih)]
                         for idx in forehead_indices]
                    )
                    x, y, w, h = cv2.boundingRect(forehead_points)

                    # Crop forehead region
                    forehead_region = frame[y:y + h, x:x + w]

                    # Compute mean RGB values from the forehead region
                    if forehead_region.size > 0:
                        mean_rgb = np.mean(forehead_region.reshape(-1, 3), axis=0)

                        # Extract rPPG signal using CHROME method
                        raw_signal = mean_rgb[1] - (mean_rgb[0] + mean_rgb[2]) / 2
                        rppg_signal_buffer.append(raw_signal)
                        timestamps_buffer.append(time.time())

        # Retain only the last 5 seconds of data
        if len(timestamps_buffer) > fps * 5:
            rppg_signal_buffer = rppg_signal_buffer[-fps * 5:]
            timestamps_buffer = timestamps_buffer[-fps * 5:]

        # Process rPPG signal if enough data is available
        if len(rppg_signal_buffer) >= fps * 5:
            # Apply a bandpass filter to the rPPG signal
            filtered_signal = bandpass_filter(
                rppg_signal_buffer,
                low_cutoff=0.7,
                high_cutoff=3.0,
                fps=fps
            )

            # Calculate HR and HRV
            hr, hrv, _ = compute_metrics(filtered_signal, fps)

            # Calculate eye redness from the last frame
            last_frame = frames[-1]
            left_eye_indices = [33, 133, 160, 158, 153, 144, 145, 362]
            right_eye_indices = [362, 263, 386, 385, 380, 373, 374, 382]
            eye_redness = extract_eye_redness(last_frame, face_landmarks, left_eye_indices, right_eye_indices)

            # Classify drunkenness
            drunk_level = classify_drunkness(hr, hrv, eye_redness)

            return {
                "heart_rate": hr,
                "hrv": hrv,
                "eye_redness": eye_redness,
                "drunk_level": drunk_level,
            }

        return {"status": "Not enough data for processing"}
    except Exception as e:
        logging.error(f"Error processing frames: {e}")
        return {"error": str(e)}
