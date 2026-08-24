# Daily Attendance & TA/DA Tracker App — Spec

## App Overview

Build a mobile app for employees to mark daily attendance and track TA/DA (travel/daily allowance) claims. Each employee logs their work status per day, exports a color-coded calendar PDF, and records expense entries tied to specific days.

## Business Context

- The company's pay month runs from the 26th of one month to the 25th of the next month. All calendar views, data grouping, and PDF exports must follow this cycle, not the standard calendar month.
- Employees work either a day shift or a night shift.
- Each day gets exactly one status. Available statuses:
  - Day shift (worked)
  - Night shift (worked)
  - On leave
  - Weekend
  - Holiday
  - Absent

## User Authentication

- Login with name and employee ID. No password.
- Once logged in, the device remembers the user. They stay logged in across app restarts and reinstalls, until they tap "Log out."
- Support multiple employees on one device if they log out and a different ID logs in. Each employee ID has its own data set.

## Core Features

### 1. Daily Attendance Marking
- Calendar view for the current pay month (26th to 25th).
- Tap a day to assign one of the six statuses.
- Each status has a distinct color. Use the same color key everywhere: the in-app calendar, the exported PDF, and any summary screen.
- Users can navigate to past pay months and edit or view past entries.

### 2. Calendar PDF Export
- Button to generate a PDF for the selected pay month.
- The PDF shows a calendar grid with each day colored by its status, matching the in-app color key.
- Include a legend mapping colors to statuses.
- Include employee name, employee ID, and the month range (e.g. "26 Jul – 25 Aug 2026") in the header.
- The exported PDF shows attendance status only. TA/DA entries are not included in this PDF.

### 3. TA/DA Tracking
- On any day, users can add one or more TA/DA entries.
- Each entry has three fields: purpose, amount, remarks.
- Users can add, edit, and delete entries for a given day.
- Provide a monthly summary view listing all entries for the selected pay month, with a total amount.
- Optional: allow a separate PDF or CSV export of the TA/DA summary for the month. Confirm with the client whether this is needed; the original requirements do not ask for it, but it is a natural companion to the attendance PDF.

## Data Storage

All data is stored internally on the device. No cloud backend, no server, no account system beyond the local name/employee ID login.

- Store attendance and TA/DA data in on-device storage (SQLite for structured records, or a local key-value store for smaller data volumes).
- Data persists across app restarts and app updates.
- If the app is uninstalled, its data is removed with it. Data does not need to reappear after reinstall.
- No network dependency for saving or reading data. The app works fully offline at all times.

## Non-Functional Requirements

- Fully offline app. No network calls required for any core feature.
- PDF generation runs entirely on-device (client-side PDF library), with no network dependency.
- Keep the color palette accessible: avoid relying on color alone, add a short status label or icon on each day cell too.

## Suggested Tech Stack

- Frontend: React Native or Flutter, for a single codebase across Android and iOS.
- Local storage: SQLite (via a wrapper like WatermelonDB or Drift, or plain SQLite) for attendance and TA/DA records.
- PDF generation: a client-side library (e.g. `react-native-html-to-pdf` or `pdf-lib`), run entirely on-device.

## Open Questions to Confirm Before Build

- Does login need any verification (e.g. employee ID validated against an HR list), or is it open self-entry? Ans. No login verification required, the name and ID are taken only to print on the attendance sheet.
- Should managers or admins have a view across all employees, or is this single-user only? Ans: This app is for employee self use only.
- Retention: how long should past pay-month data stay accessible in the app? Ans: Data should be accessible until the app is uninstalled. 
- Should the TA/DA data get its own export, separate from the attendance calendar PDF? Ans: Yes, TA/DA data should have its own export.
- Should users get a manual backup/export option (e.g. export all data to a file), as a safety net since uninstalling erases everything? Ans. No manual backup/export option is required.