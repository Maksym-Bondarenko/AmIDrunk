# 🍹 AmIDrunk? : FRONTEND

Welcome to the **AmIDrunk Frontend**, a fun and interactive application that works alongside the backend to offer exciting features like estimating alcohol levels, reaction-based mini-games, and engaging UI components. Whether you're testing your reaction speed or running in a Beer-themed endless runner, this app has something for everyone!

---
## 🌟 Features

- 🧪 **Alcohol Estimation Tools**
    - Calculate your intoxication level based on weight, height, and alcohol consumed.
    - Measure reaction speed to assess sobriety.
- 🎮 **Mini-Games**
    - Beer Runner: Navigate through obstacles in a fun endless-runner style game.
    - Reaction Game: Tap quickly on random circles to measure your reaction speed.
- 🖼️ **Beautiful UI**
    - Intuitive navigation with 8-bit-style icons and fun animations.
    - Fully responsive design across multiple devices.

---
## 🚀 Getting Started

### Prerequisites
Before running the project, make sure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Latest version recommended)
- [Dart SDK](https://dart.dev/get-dart)
- An emulator or physical device (iOS/Android).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repository-url.git
   cd frontend
   ```
2. Install dependencies:
    ```dart
    flutter pub get
    ```
3. Set up assets: Make sure the required assets (fonts, images, sounds, etc.) are in the assets/ folder. Update the pubspec.yaml file to include:
    ```yaml
    flutter:
    assets:
    - assets/icons/
      - assets/images/
      - assets/beer_runner/images/
      - assets/beer_runner/music/
      - assets/beer_runner/sfx/
    ```
4. Run the app:
    ```dart
    flutter run
    ```

---
## 📂 Project Structure

```plaintext
frontend/
├── android/               # Android-specific files
├── assets/                # App assets (icons, images, music, etc.)
│   └── beer_runner/       # Assets specific to Beer Runner game
├── ios/                   # iOS-specific files
├── lib/                   # Main source files
│   ├── games/             # Mini-games like Endless Runner and Beer Runner
│   ├── screens/           # UI screens
│   ├── services/          # Backend API interactions
│   └── widgets/           # Reusable UI components
├── linux/                 # Linux-specific files
├── macos/                 # macOS-specific files
└── pubspec.yaml           # Flutter configuration file
```

---
## ⚙️ Configuration

### Updating Assets

Whenever you add new assets (like images or sounds), update the pubspec.yaml file:
```yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
    - assets/beer_runner/images/
    - assets/beer_runner/music/
    - assets/beer_runner/sfx/
```

### API Endpoints
The app communicates with the backend using the following endpoints:
- /process_batch: Upload frames and retrieve analysis results.
- /health_check: Check if the backend is running.
You can configure the backend URL in the services/ directory if needed.

---
## 🔑 Key Modules

- **Games**:
    - **Beer Runner**: A challenging endless runner game with custom animations and assets.
    - **Reaction Game**: A fun reaction-time game to estimate sobriety.
- **Screens**:
  - **Main Screen**: A hub to navigate between tools and games.
  - **Estimation Tools**: Calculate intoxication level with provided inputs.
- **Services**:
  - Responsible for communicating with the backend.

---
## 🔮 Future Enhancements

- 🔍 **Advanced Eye-Tracking**: Implement FaceMesh detection for eye movement-based reaction time.
- 🌟 **More Mini-Games**: Add new engaging games for users to play.
- 🎨 **Enhanced Animations**: Improve UI animations for a smoother user experience.
- 📊 **Statistics Dashboard**: Allow users to track their performance over time.

---
## 🛠️ Example Workflow

1. **Launch the App**: Open the app on your device or emulator.
2. **Select a Feature**: Choose a mini-game, reaction test, or intoxication estimation tool.
3. **Interact with the App**: Enter your details, play the games, and see the results.
4. **Enjoy**: Experience the fun and insights the app provides!
