import cv2
import mediapipe as mp
import numpy as np
import time

from src.data_processing.drunkness_classifier import classify_drunkness
from src.data_processing.metrics import compute_metrics
from src.utils import bandpass_filter


mp_face_mesh = mp.solutions.face_mesh


def capture_live_video_with_face_mesh(fps, time_window_sec, rppg_extraction_method):
    """
    Capture live video, zoom into the facial region, and process rPPG signals.

    :param fps: Frames per second.
    :param time_window_sec: Time window for analysis.
    :param rppg_extraction_method: Function to extract rPPG signals (e.g., CHROME).
    :return: Filtered rPPG signal, timestamps, HR, and HRV values.
    """
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Unable to access the webcam.")
        return [], [], [], []

    print("Press 'q' to stop the video capture.")
    rppg_signal = []
    timestamps = []
    hr_values = []
    hrv_values = []
    start_time = time.time()

    last_hr_update_time = start_time

    with mp_face_mesh.FaceMesh(static_image_mode=False, max_num_faces=1, refine_landmarks=True) as face_mesh:
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = face_mesh.process(rgb_frame)

            if results.multi_face_landmarks:
                for face_landmarks in results.multi_face_landmarks:
                    ih, iw, _ = frame.shape

                    # Get bounding box for the face region
                    face_points = [
                        (int(landmark.x * iw), int(landmark.y * ih))
                        for landmark in face_landmarks.landmark
                    ]
                    x, y, w, h = cv2.boundingRect(np.array(face_points, dtype=np.int32))

                    # Apply padding
                    padding = 30
                    x1 = max(x - padding, 0)
                    y1 = max(y - padding, 0)
                    x2 = min(x + w + padding, iw)
                    y2 = min(y + h + padding, ih)

                    # Crop and resize to 500x500
                    cropped_face = frame[y1:y2, x1:x2]
                    cropped_face_resized = cv2.resize(cropped_face, (500, 500))

                    # Extract rPPG signal
                    raw_signal = rppg_extraction_method(cropped_face)
                    rppg_signal.append(raw_signal)
                    timestamps.append(time.time() - start_time)

                    # Apply bandpass filter and update HR/HRV
                    if len(rppg_signal) >= fps * time_window_sec:
                        filtered_signal = bandpass_filter(
                            rppg_signal[-fps * time_window_sec:],
                            low_cutoff=0.7,
                            high_cutoff=3.0,
                            fps=fps
                        )
                        current_time = time.time()
                        if current_time - last_hr_update_time >= time_window_sec:
                            hr, hrv, _ = compute_metrics(filtered_signal, fps)
                            if hr and hrv:
                                hr_values.append(hr)
                                hrv_values.append(hrv)

                                # Classify drunkenness level
                                drunk_level = classify_drunkness(hr, hrv)
                                print(
                                    f"[{timestamps[-1]:.1f}s] HR: {hr:.2f} BPM | HRV: {hrv:.2f} ms | Level: {drunk_level}")

                            last_hr_update_time = current_time

                    # Show the cropped, resized face (standard view)
                    cv2.imshow("Live Video (Zoomed Facial Region)", cropped_face_resized)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    cap.release()
    cv2.destroyAllWindows()
    return rppg_signal, timestamps, hr_values, hrv_values