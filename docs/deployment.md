# ChatX deployment

## Deploy the backend to Render

1. Push this repository to GitHub or GitLab.
2. In Render, choose **New > Blueprint** and select the repository. Render will
   read the checked-in `render.yaml` and create the `chatx-backend` web service.
3. Add these secret environment variables in the Render dashboard:
   - `CLOUDINARY_CLOUD_NAME`
   - `CLOUDINARY_API_KEY`
   - `CLOUDINARY_API_SECRET`
   - `FIREBASE_SERVICE_ACCOUNT_JSON` (the complete Firebase Admin service-account
     JSON on one line)
   - `ZEGO_APP_SIGN`
4. Deploy and open `https://YOUR-SERVICE.onrender.com/health`. It must return
   `{"status":"ok"}`.

Render's free web service can sleep after inactivity. The first request after a
sleep may be slow; this does not affect the Flutter API configuration.

## Build the Android app

Before publishing, choose a permanent unique Android package ID. Register that
same ID in Firebase, download the matching `android/app/google-services.json`,
and configure the release SHA-1 and SHA-256 fingerprints for Google Sign-In.

Create `android/key.properties` locally as described in
`docs/android_release.md`, then run:

```sh
flutter clean
flutter pub get
flutter build appbundle --release \
  --dart-define=BASE_URL=https://YOUR-SERVICE.onrender.com
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play
Console. Increase the version in `pubspec.yaml` for every new upload.

Never commit `android/key.properties`, a keystore, Firebase service-account JSON,
Cloudinary credentials, or Zego secrets.
