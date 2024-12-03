import numpy as np


def extract_rppg_chrome(rgb_frame):
    """
    Extract the rPPG signal using the CHROME method.

    :param rgb_frame: Input RGB frame (cropped to the face).
    :return: rPPG signal value.
    """
    mean_r = np.mean(rgb_frame[:, :, 0])
    mean_g = np.mean(rgb_frame[:, :, 1])
    mean_b = np.mean(rgb_frame[:, :, 2])

    # CHROME signal calculation
    chrom_signal = 3 * mean_r - 2 * mean_g - mean_b
    return chrom_signal