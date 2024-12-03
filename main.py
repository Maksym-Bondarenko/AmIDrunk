from config.settings import FPS, TIME_WINDOW_SEC
from src.video.live_capture import capture_live_video_with_face_detection
from src.data_processing.rppg_chrome import extract_rppg_chrome
from src.data_processing.plots import plot_combined_results


def main():
    """
    Main function to run rPPG signal extraction and HR/HRV estimation.
    """
    print(f"Starting live video capture with a {TIME_WINDOW_SEC}-second window. Press 'q' to quit.")

    # Capture and process video
    rppg_signal, timestamps, hr_values, hrv_values = capture_live_video_with_face_detection(
        fps=FPS,
        time_window_sec=TIME_WINDOW_SEC,
        rppg_extraction_method=extract_rppg_chrome
    )

    # Plot combined results
    plot_combined_results(timestamps, rppg_signal, hr_values, hrv_values, TIME_WINDOW_SEC)

    print("Processing complete. Closing application.")


if __name__ == "__main__":
    main()