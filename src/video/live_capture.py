import cv2
import mediapipe as mp
import numpy as np
import time
from src.data_processing.metrics import compute_metrics
from src.data_processing.drunkness_classifier import classify_drunkness
from src.data_processing.eye_redness import extract_eye_redness
from src.utils import bandpass_filter


mp_face_mesh = mp.solutions.face_mesh


def capture_live_video_with_face_mesh(fps, time_window_sec, rppg_extraction_method):
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Unable to access the webcam.")
        return [], [], [], [], []

    print("Press 'q' to stop the video capture.")
    rppg_signal = []
    timestamps = []
    hr_values = []
    hrv_values = []
    eye_redness_values = []
    start_time = time.time()

    last_hr_update_time = start_time
    stop_video = False  # Flag to break nested loops

    with mp_face_mesh.FaceMesh(static_image_mode=False, max_num_faces=1, refine_landmarks=True) as face_mesh:
        while not stop_video:
            ret, frame = cap.read()
            if not ret:
                break

            # Check for 'q' key press to exit
            if cv2.waitKey(1) & 0xFF == ord('q'):
                stop_video = True
                break

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = face_mesh.process(rgb_frame)

            if results.multi_face_landmarks:
                for face_landmarks in results.multi_face_landmarks:
                    ih, iw, _ = frame.shape

                    # Define eye landmark indices
                    left_eye_indices = [33, 133, 160, 158, 153, 144, 145, 362]
                    right_eye_indices = [362, 263, 386, 385, 380, 373, 374, 382]

                    # Extract redness from eyes
                    eye_redness = extract_eye_redness(frame, face_landmarks, left_eye_indices, right_eye_indices)

                    # Extract rPPG signal
                    x, y, w, h = cv2.boundingRect(
                        np.array(
                            [[int(landmark.x * iw), int(landmark.y * ih)] for landmark in face_landmarks.landmark],
                            dtype=np.int32
                        )
                    )
                    padding = 30
                    x1 = max(x - padding, 0)
                    y1 = max(y - padding, 0)
                    x2 = min(x + w + padding, iw)
                    y2 = min(y + h + padding, ih)

                    cropped_face = frame[y1:y2, x1:x2]
                    cropped_face_resized = cv2.resize(cropped_face, (500, 500))

                    raw_signal = rppg_extraction_method(cropped_face_resized)
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
                                eye_redness_values.append(eye_redness)

                                # Classify drunkenness level
                                drunk_level = classify_drunkness(hr, hrv, eye_redness)
                                print(f"[{timestamps[-1]:.1f}s] HR: {hr:.2f} BPM | HRV: {hrv:.2f} ms | Redness: {eye_redness:.2f} | Level: {drunk_level}")

                            last_hr_update_time = current_time

                    # Show the cropped face on the live video feed
                    cv2.imshow("Live Video (Zoomed Facial Region)", cropped_face_resized)

    cap.release()
    cv2.destroyAllWindows()
    return rppg_signal, timestamps, hr_values, hrv_values, eye_redness_values