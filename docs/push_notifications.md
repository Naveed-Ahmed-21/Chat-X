# ChatX push notifications setup

The app handles foreground chat notifications locally and lets FCM display notification payloads while the app is in the background. Android uses `ic_chatx_notification` as its monochrome small icon. iOS displays the app icon supplied by the operating system.

## Firebase and backend

1. In Firebase Console, enable Cloud Messaging for the same Firebase project used by `firebase_options.dart`.
2. For iOS, upload an APNs authentication key in Firebase Console and enable Push Notifications for the `com.example.chatxApp` App ID in the Apple Developer account.
3. Deploy the backend with Firebase Admin credentials through Application Default Credentials or the hosting platform's service identity. The backend must have permission to read Firestore user/chat records and send Firebase Cloud Messaging messages. Do not put a service-account key in Flutter.
4. Set `BASE_URL` to the backend's HTTPS URL in release builds. The notification endpoint requires a Firebase Auth ID token and sends only to participants in the requested chat.
5. Users must grant notification permission. On Android 13 and later, this is a runtime permission; denial leaves chat usable without visible notifications.

The checked-in iOS entitlement is set to the development APNs environment. For App Store distribution, use a production push provisioning profile and verify the archived app carries the matching production `aps-environment` entitlement.

## Notification behavior

- Chat text, photos, videos, voice messages, and files notify the other members of the chat. The server authenticates the sender and derives recipients from Firestore membership.
- A successful profile save displays a local confirmation on the device performing the save.
- Android small icons must be single-color silhouettes. Android does not render the full-color launcher logo in the small icon slot; notifications use the ChatX bubble mark. iOS uses the installed ChatX app icon.
