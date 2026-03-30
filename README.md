# Task Management App — Flodo AI Assignment

A functional, visually polished Task Management Flutter app.

## Track & Stretch Goal

- **Track B: The Mobile Specialist** — Flutter + Hive local database, no backend.
- **Stretch Goal: Debounced Autocomplete Search** — 300ms debounce on search with highlighted matching text in task titles.

## Features

- **Full CRUD**: Create, Read, Update, and Delete tasks.
- **All 5 Task Fields**: Title, Description, Due Date, Status (To-Do / In Progress / Done), Blocked By.
- **Task Blocking**: If Task B is blocked by Task A, Task B's card is visually greyed out with a 🔒 icon until Task A is marked Done.
- **Persistent Drafts**: If you start typing a new task and swipe back, your text is restored when you reopen the form (via SharedPreferences).
- **Debounced Search**: 300ms debounce fires after the user stops typing; matching text is highlighted in purple within the task title.
- **Status Filter**: Dropdown on the main screen to filter tasks by All / To-Do / In Progress / Done.
- **2-Second Simulated Delay**: All Create and Update operations include a 2-second async delay. The UI shows a loading spinner and the Save button is disabled during this time.
- **Premium UI**: Google Fonts (Outfit), purple gradient hero card, smooth layouts.

## Setup Instructions

1. **Prerequisites**: Install Flutter SDK ([flutter.dev](https://flutter.dev/docs/get-started/install)).

2. **Clone the repository**:
   ```bash
   git clone https://github.com/malavika-biju/task-management-app.git
   cd task-management-app
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Generate Hive adapters** (if regenerating):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

> The app runs on Windows, Android, iOS, and Web. Tested on Windows desktop.

## Technical Decisions

| Concern | Choice | Why |
|---|---|---|
| State Management | `flutter_bloc` | Predictable state, clean separation of UI and logic |
| Local Storage | `hive_flutter` | Fast, typed NoSQL; perfect for task objects |
| Draft Persistence | `shared_preferences` | Lightweight key-value; ideal for ephemeral form state |
| Architecture | Service/BLoC pattern | Decouples UI from data logic |
| Debounce | `dart:async` `Timer` | No extra dependency; cancels previous timer on each keystroke |

## AI Usage Report

### Prompts That Were Most Helpful
- *"Design a premium Flutter task card with a greyed-out blocked state and a lock icon, no external packages."*
- *"How do I implement 300ms debounced search in a Flutter BLoC using only dart:async Timer, and cancel it properly when the bloc is closed?"*
- *"Implement a BlocListener-based auto-pop after an async save operation, replacing a raw Future.delayed timer."*
- *"RichText widget in Flutter to highlight matching substrings case-insensitively with a purple background."*

### When AI Gave Wrong Code (and How I Fixed It)
The AI initially generated the debounce using `rxdart`'s `debounceTime` transformer — which works, but adds an extra dependency. I asked it to rewrite using only `dart:async Timer`, keeping the dependency count minimal. The AI also originally suggested calling `clearDraft()` inside `_save()` before the async operation completed, which caused a race condition where the draft cleared before the bloc finished. I fixed it by moving `clearDraft()` into the `BlocListener` after `isProcessing` transitions to false.

## Demo Video
[Google Drive Demo Video Link] — *Please record and add link before submission*
