# Practical 6 — Notes App (Shared Preferences)

Minimal Flutter Notes app demonstrating login, Remember Me, dark mode,
and notes persisted with Shared Preferences.

## Features

- Login screen with "Remember me" using `SharedPreferences`
- Dashboard with dark mode toggle
- Notes CRUD (add, edit, delete) persisted locally
- Profile screen showing user details

## Run

From the `practical_6` folder:

```powershell
flutter pub get
flutter run
```

## Persistence details

- Notes are stored as JSON under key `practical6_notes` in `SharedPreferences`.
- Remember-me stores `remember`, `email`, and `name` keys.

## Embedding video or demo in README

GitHub may not autoplay MP4s embedded in `README.md`. Recommended approaches:

- Use Git LFS to store the MP4 (already configured for this repository).
- Convert a short clip to an animated GIF and embed it:

```md
![Demo GIF](media/practical1.gif)
```

- Or link to the MP4 so visitors can open it in the browser:

```md
[Watch demo](media/practical1.mp4)
```

If you want, I can create a GIF (short clip) from `media/practical1.mp4` and add it here.

## Notes

- This is a minimal educational implementation focused on Shared Preferences.
- For production apps prefer a database for structured data (e.g., SQLite).

---

If you'd like, I can now:

- Convert the video to GIF and embed it in this README.
- Push commits and create a PR.
