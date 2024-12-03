from scipy.signal import butter, filtfilt
import numpy as np


def normalize_signal(signal):
    """
    Normalize a signal to have zero mean and unit variance.

    :param signal: Input signal (list or array).
    :return: Normalized signal.
    """
    return (signal - np.mean(signal)) / np.std(signal)


def bandpass_filter(signal, low_cutoff, high_cutoff, fps, order=5):
    """
    Apply a bandpass filter to the signal.

    :param signal: Input signal (array-like).
    :param low_cutoff: Low cutoff frequency in Hz.
    :param high_cutoff: High cutoff frequency in Hz.
    :param fps: Frames per second (sampling rate).
    :param order: Order of the filter.
    :return: Filtered signal.
    """
    nyquist = 0.5 * fps
    low = low_cutoff / nyquist
    high = high_cutoff / nyquist
    b, a = butter(order, [low, high], btype="band")
    return filtfilt(b, a, signal)