def classify_drunkness(hr, hrv, eye_redness):
    """
    Classify the drunkenness level based on HR, HRV, and eye redness.

    :param hr: Heart rate (BPM).
    :param hrv: Heart rate variability (ms).
    :param eye_redness: Average eye redness value.
    :return: Drunkenness level (str).
    """
    if eye_redness < 50 and hr < 90 and hrv > 40:
        return "Sober"
    elif 70 <= eye_redness < 100 or (90 <= hr < 110 and 20 <= hrv <= 40):
        return "Tipsy"
    elif eye_redness >= 100 or (hr >= 110 and hrv < 20):
        return "Extremely Drunk"
    else:
        return "Unknown"