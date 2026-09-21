# Simple Notes App (Flutter + Firebase + Provider)

## Setup
1. `flutter create notes_app`, then copy `lib/`, `pubspec.yaml` and `firestore.rules` from this folder over the new project.
2. Create a Firebase project at https://console.firebase.google.com
   - Authentication -> Sign-in method -> enable **Email/Password**
   - Firestore Database -> create database -> paste `firestore.rules` in the Rules tab and publish
3. Install the CLIs and link the app (this generates `lib/firebase_options.dart`):
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   flutter pub get
   flutter run
   ```

## Structure
- `models/` Note model (toJson / fromJson)
- `services/` Firebase Auth + Firestore calls only
- `providers/` Auth, Notes and Theme state (Provider / ChangeNotifier)
- `theme/` Light and Dark ThemeData
- `screens/` Auth gate, Auth (sign in / sign up), Home (list), Note form (create / edit)
## Application Demo

![Application Demo](screenshots/demo.gif)