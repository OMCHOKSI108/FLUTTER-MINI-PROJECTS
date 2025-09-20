# Practical 1 — Mobile Navigation and Data Passing (Flutter)

This repository contains Practical 1 for the Mobile Application Development course. The goal of this exercise is to implement a basic multi-screen Flutter application that demonstrates navigation, routing, and passing data between screens. The app includes a simple splash/login flow, a dashboard for the signed-in user, and a profile screen that displays user information passed from the dashboard.

Project structure highlights:
- `lib/login.dart`: Login screen (collects username and navigates to dashboard).
- `lib/dashboard.dart`: Dashboard screen that greets the user (shows "Hi {username}") and provides a button to open the profile.
- `lib/profile.dart`: Profile screen that displays the user's name and email in the format `name = {name}` and `email = {email}`. The screen accepts both named-route arguments and constructor parameters.
- `lib/main.dart`: App entry point. Registers routes and sets the initial route to the login screen.

Key learning outcomes:
- Understand Flutter's widget tree and how screens are composed.
- Implement navigation using both named routes (`Navigator.pushNamed`) and direct navigation (`Navigator.push` with a `MaterialPageRoute`).
- Pass data between screens via route arguments and constructor parameters.

How navigation and data passing work in this project:
- The app uses `MaterialApp` routes for named navigation. The `ProfilePage` class exposes a `routeName` constant so it can be used with `Navigator.pushNamed`.
- `DashboardPage` reads route arguments (if any) and greets the user with the text `Hi {username}`. When the profile button is pressed, `DashboardPage` forwards the `name` and `email` as arguments to the profile route.
- `ProfilePage` accepts optional constructor parameters (`username`, `email`) so it can also be pushed directly. The page falls back to route arguments when constructor parameters are not provided, and shows sensible defaults (`No Name`, `No Email`) when nothing is available.

Running the app (development):
1. Ensure you have Flutter installed and an emulator or device connected.
2. From the repository root, run `flutter pub get` to fetch dependencies.
3. Launch the app with `flutter run` or use your IDE's run/debug controls.

Notes and suggestions:
- The implementation focuses on core navigation concepts; UI is intentionally minimal to highlight routing and data flow.
- You can extend the project by adding a proper splash screen, input validation on the login screen, and more robust state management if required.

Course alignment:
This practical aligns with CO1 (learning outcomes for widget tree, navigation and routing) and is expected to take approximately 2 hours to implement and explore.


## 🎥 Demo Video

Here's a demonstration of the Flutter Navigation and Data Passing app:

https://github.com/OMCHOKSI108/FLUTTER-MINI-PROJECTS/assets/your-user-id/practical1.mp4

> **Note**: If the video doesn't load above, you can:
> -  **[Download the video](./media/practical1.mp4)** to watch locally
> -  **[View raw video file](https://github.com/OMCHOKSI108/FLUTTER-MINI-PROJECTS/raw/main/practical_1/media/practical1.mp4)** directly

## 📁 Media & GitHub Notes

The demo video is stored in `media/practical1.mp4` using **Git LFS** (Large File Storage) to efficiently handle large media files without bloating the repository.

✅ **Git LFS is already configured for this repository** - the video will be properly versioned and accessible.

### For other projects, here's how to set up Git LFS:

```powershell
# One-time setup for new repositories
git lfs install
git lfs track "*.mp4"
git lfs track "*.mov" 
git lfs track "*.gif"
git add .gitattributes

# Add your media files
git add media/
git commit -m "Add demo video via Git LFS"
git push origin main
```

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
