# alu_student_assistant

A mobile application that serves as a personal academic assistant for ALU students. 
Your app should help users organize their coursework, track their schedule, 
and monitor their academic engagement throughout the term.

## Features (Core Requirements)
- **Dashboard**: today’s date + academic week, today’s sessions, assignments due in 7 days, pending assignment count, overall attendance %, and a warning when attendance is below 75%.
- **Assignments**: create, view (sorted by due date), edit, complete, and delete assignments.
- **Schedule**: create, view weekly sessions, edit/delete sessions, and record attendance (Present/Absent) per session.
- **Attendance tracking**: attendance % is calculated automatically from sessions where attendance is recorded; history view is available from the dashboard.
- **Settings**: enable/disable in-app reminder popups and clear demo data.
- **Reminders (in-app)**: optional assignment reminder (days-before + time) that triggers a popup while the app is open.

## Setup
1. Install Flutter (stable channel).
2. Clone this repo.
3. Run `flutter pub get`.
4. Launch with `flutter run`.

## Project Structure (Clean & Explainable)
- `lib/app.dart`: app entry widget, theme, and bottom navigation shell.
- `lib/shared/`
  - `theme/`: ALU color palette + text styles.
  - `state/`: `AppState` (single source of truth) + `AppStateScope` (InheritedNotifier).
  - `widgets/`: reusable UI widgets (buttons, pickers, cards).
- `lib/features/`
  - `dashboard/`: dashboard UI and summary widgets.
  - `assignments/`: assignment model + list + form.
  - `sessions/`: session model + weekly schedule + form.
  - `attendance/`: attendance history screen and indicator widget.
- `lib/utils/`: small helpers (date/week calculations, attendance computation).

## State Management (How data flows)
- The app uses a single `ChangeNotifier` (`AppState`) to store:
  - `assignments`
  - `sessions` (includes attendance per session)
- UI reads state via `AppStateScope.of(context)` and rebuilds automatically when `notifyListeners()` is called.
- Reminder popups are handled by a separate `ChangeNotifier` (`ReminderService`) exposed via `ReminderServiceScope`.

## Architecture Notes (What to explain in the demo)
- **Single source of truth:** `AppState` owns all lists and business rules (filtering/sorting/attendance %).
- **Feature-first UI:** each screen lives under `lib/features/<feature>/` with its widgets and models.
- **Reminder popup behavior:** reminders are intentionally “in-app only” (they trigger while the app is open) to satisfy the rubric popup requirement without complex OS notification setup.
- **Attendance rules:** attendance % is calculated only from sessions where Present/Absent is recorded; until then the dashboard shows `N/A`.

## Contribution
- Branch: `feature/<name>`
- Commit style: Conventional commits
- Run `flutter format .` before pushing
