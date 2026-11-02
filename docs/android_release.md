# Android release setup

Release builds require an upload keystore. Do not use the Android debug key for a store release and do not commit the keystore or `android/key.properties`.

Create `android/key.properties` locally with the values for your upload key:

```properties
storeFile=/absolute/path/to/chatx-upload-key.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

Then build with:

```sh
flutter build appbundle --release --dart-define=BASE_URL=https://YOUR_BACKEND_HOST
```

Before publishing, replace the current `com.example.chatx_app` application ID with ChatX's permanent Android package ID, register that same ID in Firebase, download the matching `google-services.json`, and configure the release SHA-1/SHA-256 fingerprints for Google Sign-In. Changing the application ID after publishing creates a different Android app.
