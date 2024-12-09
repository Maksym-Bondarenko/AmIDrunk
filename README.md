# 🍸🥂🍻🍺 Drunkness Level Estimation Application

This project is a comprehensive platform designed to estimate an individual's level of intoxication through various
mini-games, reaction-time tests, heart rate (HR), heart rate variability (HRV), and eye redness analysis using advanced
technologies. It includes both a **frontend** built with Flutter and a **backend** using FastAPI.

---

## 🚀 Features

- **Backend Functionality**:
   - Drunkness estimation using heart rate, HRV, and eye redness metrics.
   - Support for reaction-time-based sobriety tests.
   - REST API for frontend integration.
   - Modular and extendable architecture for new features.

- **Frontend Functionality**:
   - Interactive and user-friendly Flutter-based interface.
   - Real-time mini-games like a bottle-spinning game and reaction tests.
   - Integration with the backend for real-time results and data visualization.
   - 8-bit styled game and application assets.

- **Mini-Games**:
   - **Reaction Time Test**: Calculate average reaction time for sobriety estimation.
   - **Bottle-Spinning Game**: Fun game to randomly select a participant.
   - **Endless Runner Game**: A challenging mini-game for entertainment.

---

## 📂 Project Structure

```plaintext
project-root/
├── backend/
│   ├── src/
│   ├── tests/
│   ├── requirements.txt
│   └── README.md
├── frontend/
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── README.md
└── README.md
```

---

## 🛠️ Getting Started

### Prerequisites

1. Backend:
   - Python 3.9+
   - FastAPI and required Python libraries (requirements.txt).
2. Frontend:
- Flutter SDK (Latest stable version).
- Android Studio / Xcode for emulators or a physical device.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/drunkness-estimation.git
   cd drunkness-estimation
   ```
2. Install dependencies:
   - **Backend**:
      ```bash
      cd backend
      python -m venv venv
      source venv/bin/activate  # or venv\Scripts\activate on Windows
      pip install -r requirements.txt
      ```
   - **Frontend**:
      ```bash
      cd frontend
      flutter pub get
      ```
3. Set up assets:

- Place required 8-bit styled assets in the frontend/assets/ directory.

### Running the Application

- **Backend**:
   ```bash
   uvicorn backend.src.main:app --reload 
   ```
- **Frontend**:
   ```bash
   flutter run
   ```

4. Access the application on your connected device or emulator.

---

## ⚙️ Configuration

- **Backend**:
   - Modify environment variables in backend/settings.py for API configurations.
   - Add new metrics in backend/src/data_processing.
- **Frontend**:
   - Update API endpoints in frontend/lib/services/api_service.dart.
   - Add new features/screens in frontend/lib/screens.

---

## 📋 Key Modules

### Backend:

- ***rppg_service***: Processes frames to extract HR and HRV data.
- ***eye_redness***: Analyzes redness in the eyes.
- ***metrics***: Computes metrics such as HR and HRV.
- ***API Endpoints***: Handles requests from the frontend.

### Frontend:

- ***API Service***: Manages HTTP requests to the backend.
- ***Screens***: Implements mini-games and tests for user interactions.
- ***Assets***: Contains all 8-bit styled images used in the application.

---

## 🛤️ Future Enhancements

- Add support for new sobriety tests (e.g., voice-based tests).
- Introduce multiplayer modes for mini-games.
- Extend backend to analyze more physiological data.
- Include better data visualization in the frontend.

---

## 🔄 Example Workflow

1. User starts the app on their device.
2. Selects a test/game from the main menu.
3. Completes the game/test.
4. Backend processes data and sends results to the frontend.
5. User views estimated sobriety level and feedback in the app.

---
*For more details, check out the individual README.md files in the backend/ and frontend/ directories.*