def classify_drunkness(hr, hrv):
    """
    Classify the drunkenness level based on HR and HRV values.

    :param hr: Heart rate (BPM).
    :param hrv: Heart rate variability (ms).
    :return: Drunkenness level (str).
    """
    if hr < 60 or hrv > 50:
        return "Sober"
    elif 60 <= hr < 90 and 30 <= hrv <= 50:
        return "Tipsy"
    elif hr >= 90 and hrv < 30:
        return "Extremely Drunk"
    else:
        return "Unknown"