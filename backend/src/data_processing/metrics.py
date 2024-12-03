import numpy as np
from scipy.signal import find_peaks

from backend.src.utils import normalize_signal


def compute_metrics(signal, fps):
    """
    Compute HR and HRV metrics from the rPPG signal.

    :param signal: rPPG signal.
    :param fps: Frames per second.
    :return: HR, HRV, and peaks.
    """
    signal = normalize_signal(signal)
    peaks, _ = find_peaks(signal, distance=fps * 0.6)

    if len(peaks) > 1:
        intervals = np.diff(peaks) / fps  # Peak intervals in seconds
        hr = 60 / np.mean(intervals)  # HR in BPM
        hrv = np.std(intervals) * 1000  # HRV in ms
        return hr, hrv, peaks
    return None, None, []