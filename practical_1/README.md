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


Video demo
----------

A short video demonstrating Practical 1 is included in this repository as `practical1.mp4`. On GitHub and many Markdown renderers the video can be embedded directly; if the platform doesn't render local video files, use the link below to download/play it.

<video controls width="640">
	<source src="./media/practical1.mp4" type="video/mp4">
	Your browser does not support the video tag. You can download the demo here: [practical1.mp4](./media/practical1.mp4)
</video>

Media & GitHub notes
--------------------

The demo video has been moved to `media/practical1.mp4` to keep large files organized. If your media files are large, consider using Git LFS to store them instead of keeping them in the main repository. To move the file locally (PowerShell):

```powershell
mkdir media
Move-Item -Path .\practical1.mp4 -Destination .\media\practical1.mp4
git add media/practical1.mp4 README.md
git commit -m "Add demo video and update README"
git push
```

To use Git LFS for large files:

```powershell
git lfs install
git lfs track "media/*.mp4"
git add .gitattributes
git add media/practical1.mp4
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
