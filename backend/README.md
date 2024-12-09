# 🥃 AmIDrunk? : BACKEND

This repository provides the backend for the **Drunkenness Estimation Application**, which processes biometric data to
classify the user's level of drunkenness. The backend uses advanced signal processing, computer vision, and Mediapipe
for real-time analysis.

---

## 📋 Features

- **Real-time Analysis**: Processes live data to compute HR, HRV, and eye redness.
- **Batch Processing**: Accumulates frames and calculates metrics from 10-second intervals.
- **Drunkenness Classification**: Classifies levels such as `Sober`, `Tipsy`, and `Extremely Drunk`.
- **Signal Filtering**: Implements bandpass filtering for noise reduction in rPPG signals.
- **Eye Redness Detection**: Estimates redness using Mediapipe Face Mesh.
- **Modular Architecture**: Organized for easy integration and expansion.

---

## 📁 Directory Structure

```plaintext
backend/
├── main.py                     # Entry point for the server.
├── settings.py                 # Configuration and environment settings.
├── logger.py                   # Logging setup for debugging and monitoring.
├── services/
│   ├── rppg_service.py         # Core rPPG signal processing logic.
│   ├── metrics_service.py      # Calculation of HR, HRV, and other metrics.
├── utils/
│   ├── signal_processing.py    # Signal filtering and normalization utilities.
│   ├── helpers.py              # General helper functions.
├── data_processing/
│   ├── eye_redness.py          # Extracts redness levels from eye regions.
│   ├── drunkness_classifier.py # Classifies drunkenness using physiological data.
├── tests/                      # Unit and integration tests.
│   ├── test_rppg.py            # Tests for rPPG signal processing.
│   ├── test_metrics.py         # Tests for metrics calculations.
```

---

## 🛠️ How It Works

### Input Data

The backend receives a batch of camera frames from the frontend every second. These batches are used to process and
calculate physiological metrics.

### Processing Pipeline

1. **Frame Decoding**: Converts raw YUV frames to RGB format for further processing.
2. **Face Mesh Detection**: Mediapipe detects and tracks facial landmarks.
3. **Signal Extraction**: Extracts the rPPG signal from the forehead region.
4. **Metrics Calculation**:
    - Computes Heart Rate (HR) and Heart Rate Variability (HRV).
    - Applies signal filtering and peak detection for accuracy.
5. **Eye Redness Analysis**: Estimates redness levels from the eye regions using Mediapipe Face Mesh.
6. **Classification**: Combines HR, HRV, and eye redness to determine the user's level of drunkenness.

### Output

The backend returns a JSON response containing the following:

- Heart Rate (HR)
- Heart Rate Variability (HRV)
- Eye Redness
- Drunkenness Level (e.g., Sober, Tipsy, Extremely Drunk)

**Example**:

```json
{
  "heart_rate": 78.3,
  "hrv": 45.1,
  "eye_redness": 72.5,
  "drunk_level": "Tipsy"
}
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.8+
- Required Libraries: Install dependencies using:

```bash
pip install -r requirements.txt
```

---

### Running the Server

1. Clone the repository:

```bash
git clone https://github.com/your-repo/drunkenness-estimation.git
cd drunkenness-estimation/backend
```

2. Start the background server:

```bash
python main.py
```

3. Verify the Server:
    - Open a browser or use a tool like curl to check the health endpoint:
    ```bash
   http://127.0.0.1:8000
   ```
    - You should see a response like:
   ```json
   {
      "status": "OK",
      "message": "Backend is running!"
   }
   ```

The server runs at http://127.0.0.1:8000.

---

## ⚙️ Configuration

**settings.py**
Manage configurations like:

1. Frame buffer size: Number of frames per batch.
2. Mediapipe settings: Control face mesh parameters.
3. Logging level: Adjust verbosity for debugging.

---

## ✨ Key Modules

1. **main.py**
    - Try point of the backend using FastAPI.
    - Exposes two endpoints:
    - /: Health check endpoint.
    - /process_batch/: Processes batches of frames.
2. **rppg_service.py**
    - Handles real-time rPPG signal processing.
    - Accumulates frames and extracts signal from the forehead region.
3. **metrics_service.py**
    - Computes HR and HRV metrics from rPPG signals.
    - Uses filtering and peak detection techniques.
4. **eye_redness.py**
    - Exracts redness values from eye landmarks.
    - Utilizes Mediapipe’s Face Mesh to isolate eye regions.
5. **drunkness_classifier.py**
    - Classifies the user’s drunkenness level using:
    - Heart rate (HR)
    - Heart rate variability (HRV)
    - Eye redness levels
6. **signal_processing.py**
    - Contains utilities for:
    - Bandpass filtering
    - Signal normalization
    - Noise reduction

### Frontend Integration

Ensure the frontend sends requests to the backend’s /process_batch/ endpoint to process frame batches.
Modify the backend URL in the frontend if needed:

```dart
Uri.parse
('http://<backend-ip>:8000/process_batch/
'
)
```

---

## 🧪 Testing

### Running Unit Tests

Run the provided test cases to ensure everything works as expected:

```bash
pytest tests/
```

---

## 🛡️ Troubleshooting

### Common Issues

1. Backend not starting:
    - Ensure Python 3.8+ is installed.
    - Check if all dependencies are installed with pip install -r requirements.txt.
2. Frontend connection issues:
    - Verify that the frontend is sending requests to the correct backend IP and port.
3. Frame decoding errors:
    - Ensure that frames are properly encoded in the YUV format.

---

## 🎯 Future Enhancements

- **Eye Movement Analysis**: Integrate real-time eye tracking for more precise drunkenness estimation.
- **Extended Metrics**: Add additional physiological markers like respiratory rate.
- **Cloud Deployment**: Deploy on AWS/GCP for better scalability.

---

## 📝 Example Workflow

1. The **frontend** sends a batch of frames to /process_batch/.
2. The **backend**:
    - decodes frames.
    - Extracts rPPG signals and eye redness.
    - Computes HR and HRV.
    - Classifies drunkenness.
    - Returns metrics and drunkenness level to the frontend.
3. Returns metrics and drunkenness level to the frontend.

```json
{
  "heart_rate": 120.0,
  "hrv": 60.0,
  "eye_redness": 80.0,
  "drunk_level": "Extremely Drunk"
}
```