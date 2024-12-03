from matplotlib import pyplot as plt


def plot_combined_results(timestamps, signal, hr_values, hrv_values, drunk_levels, time_window_sec):
    """
    Plot the filtered rPPG signal, HR, HRV trends, and drunkenness levels in a single plot.

    :param timestamps: Time points for the signal.
    :param signal: Filtered rPPG signal.
    :param hr_values: Heart Rate (HR) trends.
    :param hrv_values: Heart Rate Variability (HRV) trends.
    :param drunk_levels: Drunkenness levels corresponding to HR/HRV measurements.
    :param time_window_sec: Step interval for HR and HRV trends (in seconds).
    """
    plt.figure(figsize=(12, 8))

    # Plot filtered rPPG signal
    plt.subplot(3, 1, 1)
    plt.plot(timestamps, signal, label="Filtered rPPG Signal", color="blue")
    plt.title("Filtered rPPG Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.legend()

    # Plot HR trends
    hr_time = [i * time_window_sec for i in range(len(hr_values))]
    plt.subplot(3, 1, 2)
    plt.plot(hr_time, hr_values, label="HR (BPM)", marker="o", color="green")
    plt.title("Heart Rate (HR) Over Time")
    plt.xlabel("Time (s)")
    plt.ylabel("HR (BPM)")
    plt.legend()

    # Annotate drunkenness levels on HR trends
    for i, drunk_level in enumerate(drunk_levels):
        plt.annotate(drunk_level, (hr_time[i], hr_values[i]), textcoords="offset points", xytext=(0, 10), ha="center")

    # Plot HRV trends
    hrv_time = [i * time_window_sec for i in range(len(hrv_values))]
    plt.subplot(3, 1, 3)
    plt.plot(hrv_time, hrv_values, label="HRV (ms)", marker="o", color="orange")
    plt.title("Heart Rate Variability (HRV) Over Time")
    plt.xlabel("Time (s)")
    plt.ylabel("HRV (ms)")
    plt.legend()

    plt.tight_layout()
    plt.show()