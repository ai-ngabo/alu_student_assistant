# alu_student_assistant

We built a mobile academic assistant for African Leadership University (ALU) students.
It helps you keep up with assignments, plan academic sessions, and track attendance during the term.

## Features (Core Requirements)
- **Dashboard**: shows today’s date + academic week, today’s sessions, assignments due in 7 days, pending assignment count, and overall attendance %. When attendance drops below 75%, it shows a warning.
- **Assignments**: add assignments (title, due date, course, optional priority), edit them, mark them complete, and delete them. The list is sorted by due date.
- **Schedule**: add academic sessions (title, date, start/end time, optional location, and type), edit/delete sessions, and record attendance (Present/Absent).
- **Attendance**: attendance % updates automatically based on recorded sessions, and you can view a summary + history.
- **Settings**: turn in-app reminders on/off, test a reminder popup (for the demo), and clear demo data.
- **Reminders (in-app)**: optional reminder on an assignment (days-before + time). The popup triggers while the app is open.

## Setup
1. Install Flutter (stable channel).
2. Clone this repo.
3. Run `flutter pub get`.
4. Run the app with `flutter run`.

## Navigation
- Bottom tabs: **Dashboard**, **Assignments**, **Schedule**
- Top-right avatar menu: **Attendance**, **Attendance history**, **Settings**

## Project Structure (Clean & Explainable)
- `lib/app.dart`: theme + navigation shell (bottom tabs + avatar menu).
- `lib/shared/`
  - `theme/`: ALU color palette + text styles.
  - `state/`: `AppState` (single source of truth) + `AppStateScope` (InheritedNotifier).
  - `services/`: in-app services (e.g., reminder popups).
  - `widgets/`: reusable UI widgets (buttons, pickers, cards).
- `lib/features/`
  - `dashboard/`: dashboard UI and summary widgets.
  - `assignments/`: assignment model + list + form.
  - `sessions/`: session model + weekly schedule + form.
  - `attendance/`: attendance summary + history screens.
  - `settings/`: reminder toggles and demo utilities.
- `lib/utils/`: small helpers (date/week calculations, attendance computation).

## State Management (How data flows)
- `AppState` (a `ChangeNotifier`) holds `assignments` and `sessions` (sessions include attendance).
- Screens read state with `AppStateScope.of(context)` and update automatically when `notifyListeners()` is called.
- Reminder popups are handled by `ReminderService` (available via `ReminderServiceScope`).

## Data persistence (current)
- **Assignments**: persisted with `shared_preferences` as JSON (`AssignmentRepository`).
- **Sessions + attendance**: in-memory only for now.

## Architecture Notes (What to explain in the demo)
- **Single source of truth:** `AppState` owns the lists + rules (sorting/filtering/attendance %).
- **Feature-first UI:** we grouped code by feature so it’s easier to split work across the team.
- **Reminder popups:** intentionally “in-app only” (they trigger while the app is open) to keep setup simple and still satisfy the rubric popup requirement.
- **Attendance math:** we compute attendance from sessions that are actually marked Present/Absent; until then we show `N/A`.

## Contribution
- Branch: `feature/<name>`
- Commit style: Conventional commits
- Run `flutter format .` before pushing
