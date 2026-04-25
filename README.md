# WorldClassroom
A local AI-powered mobile application that combines **mental health support** and **educational features**, built with Flutter (Android) and powered by AI backends running on Google Colab.

## Overview
WorldClassroom runs two separate AI backends via Google Colab notebooks, which expose temporary public URLs through ngrok. The Flutter frontend (Android app) connects to these URLs to deliver AI-powered mental health and educational experiences.

## Requirements
Before you start, make sure you have the following:

- **Python** (for running Colab notebooks)
- **Flutter SDK** installed on your machine
- **Android device or emulator** (Android is the fully supported platform)
- **A Groq API key** — get one free at (https://console.groq.com/keys)
- **An ngrok account and auth token** — get one free at [https://ngrok.com](https://ngrok.com)

> **Platform note:** The app is fully supported on **Android**. Web (Chrome/Edge) requires Firebase web configuration. Windows desktop builds require Visual Studio with the "Desktop development with C++" workload.


## Getting the Project

### Option A — Download from Zenodo
1. Go to the Zenodo page for this project and click **Download**
2. Extract the downloaded `.zip` file to a folder on your computer
3. Open VS Code, click **File → Open Folder** and select the extracted folder
4. Continue from **Step 1** in the Setup section below

### Option B — Clone from GitHub
If you have Git installed, open a terminal and run:
```bash
git clone https://github.com/katoki001/emo_study.git
```
Then open the folder in VS Code and continue from **Step 1** below.

> If you don't have Git, you can also click the green **Code** button on the GitHub page and choose **Download ZIP**, then extract it just like Option A.

## Step-by-Step Setup

### Step 1 — Run the Mental Health Colab

1. Open the **Mental Health backend** Colab notebook: [Open in Colab](https://colab.research.google.com/drive/17jCNaXayeCtNCAvcknW5pHjumoZW95qJ)

2. **Cell 3** will ask you to upload a file:
```python
from google.colab import files
uploaded = files.upload()
```
When this cell runs, a file picker will appear. Upload the emotion dataset file located at:
```
datasets/emotion_data.csv
```

3. In the **last cell**, find the fourth line from the end and replace the ngrok token with your own:
```python
ngrok.set_auth_token('Your ngrok auth token here')
```

4. Run all cells in the notebook.

5. At the **end of the last cell's output**, copy the ngrok public URL that appears. It will look something like:
```
https://xxxx-xxxx-xxxx.ngrok-free.app
```
> Save this — this is your **Mental Health backend URL**.

---

### Step 2 — Run the Educational Colab

1. Open the **Educational backend** Colab notebook: [Open in Colab](https://colab.research.google.com/drive/1YEtO8aUhHpBV_3obUWYHPOYg9Tk6Ry4U)

2. In **Cell 3**, find the second line from the end and replace with your Groq API key:
```python
GROQ_API_KEY = "YOUR API KEY (GROQ)"
```

3. In the **last cell**, find lines 22–23 from the end and replace the ngrok token with your own:
```python
ngrok.set_auth_token('Your ngrok auth token here')
```

4. Run all cells in the notebook.

5. At the **end of the last cell's output**, copy the ngrok public URL that appears.
> Save this — this is your **Educational backend URL**.

---

### Step 3 — Update the Flutter Frontend

Open the project in **VS Code**.

**Place your Mental Health URL** in `lib/services/colab_ai_service.dart`, at lines **85–86**:
```dart
const String kApiBase = "https://YOUR-MENTAL-HEALTH-URL.ngrok-free.app";
// ── Paste your MENTAL HEALTH backend ngrok URL here ──
static const String baseUrl = "https://YOUR-MENTAL-HEALTH-URL.ngrok-free.app";
```

**Place your Educational URL** in two places:

In `lib/screens/education_screen.dart`, at lines **12–13**:
```dart
// ── Paste your EDUCATIONAL backend ngrok URL here ──
static const String baseUrl = "https://YOUR-EDUCATIONAL-URL.ngrok-free.app";
```

In `lib/screens/lectures_screen.dart`, at lines **11–12**:
```dart
const String _kApiBase =
    "https://YOUR-EDUCATIONAL-URL.ngrok-free.app";
```

> **Important:** The ngrok URLs change every time you restart the Colab notebooks. You will need to repeat Step 3 each time you start a new session.

---

### Step 4 — Install Flutter Dependencies

In VS Code, open a terminal and run:
```bash
flutter pub get
```
This downloads all the packages the app needs. You only need to do this once after downloading the project.

---

### Step 5 — Run the App

```bash
flutter run
```

Make sure your Android device is connected (or your emulator is running) before executing this command. To run specifically in Chrome:

```bash
flutter run -d chrome
```

---

## Project Structure

```
ai_learning_app/
├── assets/
├── datasets/
│   ├── emotion_data.csv              ← Upload this when running Mental Health Colab
│   └── physics_clean_dataset.csv
├── lib/
│   ├── data/
│   ├── l10n/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   │   ├── ai_supporter_screen.dart
│   │   ├── body_scan_screen.dart
│   │   ├── education_screen.dart     ← Educational URL goes here (lines 12–13)
│   │   ├── emotional_memories_screen.dart
│   │   ├── home_screen.dart
│   │   ├── lectures_screen.dart      ← Educational URL goes here (lines 11–12)
│   │   ├── mindful_grounding_screen.dart
│   │   ├── music_player_screen.dart
│   │   ├── playlist_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── sign_in_screen.dart
│   │   ├── sign_up_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── study_timer.dart
│   │   └── wellness_screen.dart
│   ├── services/
│   │   ├── audio_service.dart
│   │   ├── auth_service.dart
│   │   ├── colab_ai_service.dart     ← Mental Health URL goes here (lines 85–86)
│   │   └── firebase_storage_service.dart
│   ├── utils/
│   ├── widgets/
│   ├── firebase_options.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## Colab Notebooks

| Notebook | Purpose | Link |
|----------|---------|------|
| Mental Health Backend | AI mental health support and summarization via Groq (llama-3.1-8b-instant) | [Open in Colab](https://colab.research.google.com/drive/17jCNaXayeCtNCAvcknW5pHjumoZW95qJ) |
| Educational Backend | AI educational features via Groq | [Open in Colab](https://colab.research.google.com/drive/1YEtO8aUhHpBV_3obUWYHPOYg9Tk6Ry4U) |

---

## Troubleshooting

**App shows blank/white screen on web:**
Sometimes the app loading on device takes a few seconds and shows a white/blank screen before starting. This is normal — just wait a moment.

**`flutter run` fails on Windows:**
Run `flutter doctor` and install Visual Studio with the "Desktop development with C++" workload.

**`flutter pub get` fails:**
Make sure Flutter SDK is installed correctly. Run `flutter doctor` to check for any issues.

**Connection error in the app:**
The ngrok URLs expire when the Colab session ends. Re-run both Colab notebooks and update the URLs in the Flutter files again (Step 3).

**Groq API errors:**
Make sure your Groq API key is valid and has not exceeded its free tier limits.

**File upload prompt doesn't appear in Mental Health Colab:**
Make sure you are running the notebook in Google Colab (not locally). The file picker only works inside Colab.

---

## License

This project was created as a student academic project.
