import cv2
import numpy as np


def extract_eye_redness(frame, landmarks, left_eye_indices, right_eye_indices):
    """
    Extract the redness level from the eyes.

    :param frame: Input RGB frame.
    :param landmarks: Mediapipe face landmarks.
    :param left_eye_indices: Indices of the left eye landmarks.
    :param right_eye_indices: Indices of the right eye landmarks.
    :return: Average redness value of both eyes.
    """
    ih, iw, _ = frame.shape

    # Get points for the left and right eyes
    left_eye_points = np.array(
        [[int(landmarks.landmark[idx].x * iw), int(landmarks.landmark[idx].y * ih)] for idx in left_eye_indices]
    )
    right_eye_points = np.array(
        [[int(landmarks.landmark[idx].x * iw), int(landmarks.landmark[idx].y * ih)] for idx in right_eye_indices]
    )

    # Create bounding boxes for both eyes
    left_x, left_y, left_w, left_h = cv2.boundingRect(left_eye_points)
    right_x, right_y, right_w, right_h = cv2.boundingRect(right_eye_points)

    # Crop eye regions
    left_eye_region = frame[left_y:left_y + left_h, left_x:left_x + left_w]
    right_eye_region = frame[right_y:right_y + right_h, right_x:right_x + right_w]

    # Compute redness as the average red-channel intensity
    left_redness = np.mean(left_eye_region[:, :, 2]) if left_eye_region.size > 0 else 0
    right_redness = np.mean(right_eye_region[:, :, 2]) if right_eye_region.size > 0 else 0

    # Return the average redness value of both eyes
    return (left_redness + right_redness) / 2