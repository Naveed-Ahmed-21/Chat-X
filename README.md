# ChatX 💬

**ChatX** is a real-time messaging app built with **Flutter**, **Firebase**, and a **Node.js/Express** backend with **Cloudinary** integration. It provides 1-on-1 and group messaging, voice notes, rich media sharing, and real-time user presence.

---

## 🚀 Features

### 🔐 Authentication & Onboarding
- **Firebase Auth Integration**: Secure login and sign-up using Email/Password or Google Sign-In.
- **Account Management**: Password reset flows, email verification, and profile setup.

### 💬 Real-Time Messaging
- **1-on-1 & Group Chats**: Instant messaging backed by Cloud Firestore.
- **Rich Message Types**: Text, Images, Videos, Audio Voice Notes, and Document Files.
- **Interactivity**: Floating emoji reactions, message replies, message forwarding, and overlay actions.
- **Status Indicators**: Real-time message status (Sent, Delivered, Read timestamps).
- **Asset Hub**: View all shared links, media, and files within a specific chat room.

### 🎙️ Rich Media & Voice Notes
- **Voice Waveforms**: Record voice messages with live waveform visualization (`audio_waveforms`) and inline audio playback (`just_audio`).
- **Media Viewer**: Fullscreen photo view, video player (`chewie` & `video_player`), and document preview.
- **Cloudinary Storage**: High-speed image, video, audio, and document uploads via Node.js Express backend.

### 👥 Group & Profile Management
- **Group Controls**: Create custom groups, manage group members, assign admin roles, and set group avatars.
- **Presence Tracking**: Real-time user online/offline status updates (`presence_service`).
- **Custom Profiles**: Personalized user bios, profile pictures, and contact discovery.

---

## 🛠️ Tech Stack & Dependencies

### **Mobile App (Flutter)**
- **Framework**: Flutter (Dart)
- **State Management & Navigation**: [GetX](https://pub.dev/packages/get)
- **Database & Auth**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`
- **Networking**: `dio`, `cached_network_image`
- **Media & Audio**: `just_audio`, `audio_waveforms`, `record`, `video_player`, `chewie`, `image_picker`, `file_picker`
- **Utilities**: `intl`, `uuid`, `flutter_svg`, `slide_to_act`

### **Backend Service (Node.js)**
- **Runtime**: Node.js & Express
- **File Uploads**: `multer`
- **Cloud Storage**: `cloudinary`
- **Configuration**: `dotenv` (with dynamic port binding & fallback support)

---

## 📁 Project Structure

```
ChatX/
├── android/                   # Android native configuration & Gradle scripts
├── backend/                   # Node.js / Express media upload server
│   ├── config/                # Cloudinary setup
│   ├── controller/            # File upload handlers
│   ├── middleWare/            # Multer upload middleware
│   ├── routers/               # Express routes
│   ├── .env                   # Environment variables (PORT and Cloudinary keys)
│   └── index.js               # Express server entry point
├── ios/                       # iOS native configuration
├── lib/                       # Flutter Application source code
│   ├── config/                # Themes, App Colors, and Page Paths
│   ├── controller/            # GetX Controllers (Auth, Chat, Group, Profile, etc.)
│   ├── model/                 # Data Models (User, ChatRoom, Message, Group)
│   ├── pages/                 # UI Screens (Auth, Home, Chat, Group, Profile)
│   │   ├── group/             # Group management screens
│   │   ├── screens/           # Main feature screens & widgets
│   │   └── splashScreen/      # App splash screen
│   ├── repository/            # Data repositories
│   ├── services/              # Audio recording, Uploads, Presence, Downloads
│   ├── utils/                 # Utility functions & Date formatters
│   └── main.dart              # Flutter application entry point
└── pubspec.yaml               # Flutter package configuration
```

---

## 🔧 Setup & Installation

For the production deployment path, see [docs/deployment.md](docs/deployment.md).

### Prerequisites
- **Flutter SDK** (v3.19 or higher)
- **Node.js** (v18 or higher)
- **Android Studio** or **VS Code** with Flutter extension
- An active **Firebase Project** and **Cloudinary Account**

---

### 1️⃣ Backend Setup (`backend/`)

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the `backend/` directory with your Cloudinary credentials:
   ```env
   PORT=5000
   CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
   CLOUDINARY_API_KEY=your_cloudinary_api_key
   CLOUDINARY_API_SECRET=your_cloudinary_api_secret
   ```

4. Start the backend server:
   ```bash
   npm start
   ```
   > 💡 *Note: The backend automatically handles port allocation. If port `5000` is occupied, it safely falls back to the next free port (e.g., `5001`).*

---

### 2️⃣ Flutter Mobile App Setup

1. From the project root, fetch dependencies:
   ```bash
   flutter pub get
   ```

2. Add `google-services.json` to `android/app/` for Firebase configuration.

3. Verify or update backend API base URL in `lib/services/upload_service.dart` if testing on an emulator or physical device:
   ```dart
   class ApiConstants {
     static const baseUrl = "http://10.0.2.2:5000"; // Use 10.0.2.2 for Android Emulator
   }
   ```

4. Run the app on your connected device/emulator:
   ```bash
   flutter run
   ```

---

## 🌐 Backend API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Server health check endpoint |
| `POST` | `/api/upload/profile` | Uploads user profile image to Cloudinary |
| `POST` | `/api/upload/chat` | Uploads chat image attachment |
| `POST` | `/api/upload/video` | Uploads video file & returns URL + thumbnail |
| `POST` | `/api/upload/audio` | Uploads audio voice note |
| `POST` | `/api/upload/file` | Uploads general document/file attachment |

---

## 🛠️ Build & Troubleshooting Notes

- **Android Gradle Build Warning / Plugin Conflicts**: Ensure no obsolete `GeneratedPluginRegistrant.java` file resides in `android/app/src/main/java/io/flutter/plugins/`. Flutter's `FlutterActivity` automatically registers Kotlin-based plugins at runtime.
- **Port Conflict**: If running `npm start` while another service is using port 5000, `index.js` handles fallback gracefully without terminating running processes.

---

## 📄 License

This project is licensed under the **MIT License**.
