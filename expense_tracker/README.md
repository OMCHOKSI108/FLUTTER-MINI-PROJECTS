# Time Tracker (expense_tracker)

This project is a simple Flutter app for tracking time spent on projects and tasks. The app persists data locally using the `localstorage` package and provides basic screens to add, edit, group, and manage entries, projects, and tasks.

Prerequisites
- Flutter SDK installed and on `PATH`.

Quick setup (PowerShell)
1. Open PowerShell and run:

```powershell
cd d:\MAD\expense_tracker
flutter pub get
```

2. Run the app (web is convenient for inspecting Local Storage):

```powershell
flutter run -d chrome
```

Or run on a connected device/emulator:

```powershell
flutter run
```

How the app stores data
- The app uses `LocalStorage('time_tracker')` in `lib/providers/time_entry_provider.dart`.
- On the web, stored values appear in Chrome DevTools → Application → Local Storage for the app origin.
- On Android, the data file is located under the app files directory (debug builds):
	- `/data/data/com.example.expense_tracker/files/time_tracker.json` (use Device File Explorer or `adb shell run-as` to access)

Key features
- View a list of time entries on the Home screen with an empty-state message when there are none.
- Add and edit time entries: project, task, total minutes, date, and notes.
- Group entries by project using the AppBar toggle.
- Manage Projects and Tasks from the drawer.
- Local persistence: data remains across app restarts.

Developer helpers
- On first run the app seeds a set of sample Projects and Tasks (including names like `Om` and `S`).
- The Home screen has an AppBar action (magic wand icon) that seeds demo entries for quick screenshots (`seedDemoEntries()`).

Where to look in the codebase
- Main entry: `lib/main.dart` (wires the provider and initial screen).
- Models: `lib/models/project.dart`, `lib/models/task.dart`, `lib/models/time_entry.dart`.
- Provider and persistence logic: `lib/providers/time_entry_provider.dart`.
- Screens: `lib/screens/home_screen.dart`, `lib/screens/add_time_entry_screen.dart`, `lib/screens/manage_screen.dart`.

Capturing Local Storage screenshots
- Web (recommended): run with Chrome and open DevTools → Application → Local Storage → select the site origin.
	- `local-storage-empty.png`: clear storage or run before adding entries and capture the `timeEntries` key showing an empty array `[]`.
	- `local-storage-filled.png`: after adding entries (or seeding) refresh DevTools and capture the `timeEntries` key showing JSON entries.
- Android: use Device File Explorer in Android Studio or `adb shell run-as com.example.expense_tracker cat /data/data/com.example.expense_tracker/files/time_tracker.json` to view and capture the file contents.

If you want me to add more helpers
- I can add a small debug screen to display the raw saved JSON in the app for easy screenshots on any platform.
- I can add a one-button "Clear all data" control for reproducible empty-state screenshots.

Contact
- If you run into runtime exceptions or performance issues, paste the full error stack trace here and I will diagnose the cause and provide targeted fixes.

Screenshots

The repository includes sample screenshots in the `assets/` folder. You can reference them when preparing your submission or documentation:

- `assets/home-empty.png` — App home screen with no entries.
- `assets/home-entries.png` — App home screen showing multiple entries.
- `assets/local-storage-filled.png` — Example of the saved JSON visible in DevTools / local storage.
