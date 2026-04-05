# flutter_test_app

A Flutter web application with Firebase/Firestore integration for managing items.

## Features

- View, add, edit, and delete items stored in Firestore
- Item fields: name, optional description, and material type (Mild Steel, Aluminum, Stainless Steel)
- Deployed via Firebase Hosting

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.11.3)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project with Firestore enabled

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/moon-lee/flutter_test_app.git
   cd flutter_test_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app (web):
   ```bash
   flutter run -d chrome
   ```

### Firebase Configuration

The app uses Firebase Core and Cloud Firestore. Firebase options are generated in `lib/firebase_options.dart` using the FlutterFire CLI.

## Git Remote

The repository is hosted at:
```
https://github.com/moon-lee/flutter_test_app
```

To verify or set the remote:
```bash
git remote -v
# If not set, add it:
git remote add origin https://github.com/moon-lee/flutter_test_app.git
```

## Deployment

Deploy to Firebase Hosting:
```bash
flutter build web
firebase deploy
```

## Project Structure

```
lib/
  main.dart              # App entry point, Firebase initialization
  database/
    firebase_service.dart  # Firestore CRUD operations and Item model
  pages/
    items_page.dart        # Main UI page for item management
```

