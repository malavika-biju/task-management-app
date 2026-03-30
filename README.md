# Task Management App - Flodo AI Assignment

A functional, visually polished Task Management Flutter app built with **Track B: The Mobile Specialist**.

## Features

- **Core CRUD**: Create, Read, Update, and Delete tasks.
- **Isar Database**: High-performance local persistence.
- **Task Blocking**: Visual "greyed out" state for tasks blocked by incomplete dependencies.
- **Persistent Drafts**: Unsaved task data is preserved across app sessions.
- **Debounced Search**: Optimized search with a 300ms debounce to improve performance.
- **Text Highlighting**: (Stretch Goal) Matching search terms are highlighted in task titles.
- **2-Second Delay**: Simulated latency on Create/Update with clear loading states and double-tap prevention.
- **Status Filtering**: Easily filter tasks by Done, In Progress, or To-Do.
- **Premium UI**: Modern aesthetics using Google Fonts (Outfit), subtle gradients, and clean card designs.

## Technical Choices

- **State Management**: `flutter_bloc` for predictable state changes and clean separation of concerns.
- **Local Storage**: `Isar` for the main data model and `SharedPreferences` for quick draft persistence.
- **Architecture**: Service/Repository pattern to decouple UI from data logic.
- **Debouncing**: Implemented using `rxdart` operators in the Bloc layer.

## Setup Instructions

1.  **Environment**: The Flutter SDK was found at `C:\Users\malum\flutter`.
2.  **Initialize Boilerplate**:
    ```powershell
    C:\Users\malum\flutter\bin\flutter.bat create .
    ```
3.  **Install Dependencies**:
    ```powershell
    C:\Users\malum\flutter\bin\flutter.bat pub get
    ```
4.  **Codegen (Isar)**:
    ```powershell
    C:\Users\malum\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
    ```
5.  **Run the App**:
    ```powershell
    C:\Users\malum\flutter\bin\flutter.bat run
    ```

## AI Usage Report

### Prompts Used
- "Design a premium Flutter task card with a status chip and visual indication for blocked tasks."
- "Implement a debounced search logic in a Flutter Bloc that also handles text highlighting in the UI."
- "How to persist form drafts in Flutter using Cubit and SharedPreferences?"

### Helpful Code
The AI was particularly helpful in setting up the `rxdart` debounce transformer for the Search event and providing the logic for the RichText highlighting.

### Challenges/Fixes
The AI initially suggested using `Hive` for all data, but I opted for `Isar` as it's more structured for relational-like data (Blocked By field). I had to manually adjust the blocking logic to ensure it correctly checks the status of the blocker task in the global list.

## Demo Video
[Link to Google Drive Demo Video] (Placeholder - Please record as per guidelines)
