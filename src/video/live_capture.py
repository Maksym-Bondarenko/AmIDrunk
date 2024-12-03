import cv2
import mediapipe as mp
import time
from src.data_processing.metrics import compute_metrics
from src.utils import bandpass_filter

mp_face_detection = mp.solutions.face_detection


def capture_live_video_with_face_detection(fps, time_window_sec, rppg_extraction_method):
    """
    Capture live video, crop face ROI with padding, and process rPPG signals in real-time.

    :param fps: Frames per second.
    :param time_window_sec: Time window for analysis (in seconds).
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

    with mp_face_detection.FaceDetection(min_detection_confidence=0.5) as face_detection:
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = face_detection.process(rgb_frame)

            if results.detections:
                for detection in results.detections:
                    bbox = detection.location_data.relative_bounding_box
                    ih, iw, _ = frame.shape

                    # Calculate the face ROI with padding
                    x, y, w, h = int(bbox.xmin * iw), int(bbox.ymin * ih), int(bbox.width * iw), int(bbox.height * ih)
                    padding = 30
                    x1 = max(x - padding, 0)
                    y1 = max(y - padding, 0)
                    x2 = min(x + w + padding, iw)
                    y2 = min(y + h + padding, ih)

                    face_roi = frame[y1:y2, x1:x2]
                    face_roi = cv2.resize(face_roi, (500, 500))

                    # Extract rPPG signal
                    raw_signal = rppg_extraction_method(face_roi)
                    rppg_signal.append(raw_signal)
                    timestamps.append(time.time() - start_time)

                    # Apply bandpass filter to the signal
                    if len(rppg_signal) >= fps * time_window_sec:
                        filtered_signal = bandpass_filter(
                            rppg_signal[-fps * time_window_sec:],
                            low_cutoff=0.7,
                            high_cutoff=3.0,
                            fps=fps
                        )

                        # Update HR and HRV every 5 seconds
                        current_time = time.time()
                        if current_time - last_hr_update_time >= time_window_sec:
                            hr, hrv, _ = compute_metrics(filtered_signal, fps)
                            if hr and hrv:
                                hr_values.append(hr)
                                hrv_values.append(hrv)
                                print(f"[{timestamps[-1]:.1f}s] HR: {hr:.2f} BPM | HRV: {hrv:.2f} ms")
                            last_hr_update_time = current_time

                    # Show the live cropped and resized face
                    cv2.imshow("Live Video (Cropped 500x500)", face_roi)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    cap.release()
    cv2.destroyAllWindows()
    return rppg_signal, timestamps, hr_values, hrv_values