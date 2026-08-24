# Daily Attendance & TA/DA Tracker

## Purpose
Mobile app for employees to mark daily attendance and track TA/DA (travel/daily allowance) claims. Fully offline, no cloud backend.

## Attendance Statuses

| Status | Color | Short | Icon |
|--------|-------|-------|------|
| Day Shift | `#4CAF50` (Green) | D | ☀️ |
| Night Shift | `#5C6BC0` (Indigo) | N | 🌙 |
| On Leave | `#FF9800` (Orange) | L | 🏖️ |
| Weekend | `#78909C` (Grey) | W | 🛋️ |
| Holiday | `#EC407A` (Pink) | H | 🎉 |
| Absent | `#EF5350` (Red) | A | ❌ |

## Pay-Month Rule
- Runs from 26th of one month to 25th of the next month.
- All calendar views, data grouping, and PDF exports follow this cycle.

## Core Features
1. **Daily Attendance Marking** — Calendar view (26th–25th), tap to assign status, color-coded cells with labels.
2. **Calendar PDF Export** — Color-coded calendar grid with legend, employee name/ID, month range.
3. **TA/DA Tracking** — Add/edit/delete expense entries per day (purpose, amount, remarks). Monthly summary with totals.
4. **TA/DA Export** — CSV and PDF export of monthly TA/DA summary.
5. **Local Login** — Name + employee ID, device-remembered via SharedPreferences.

## Storage Model
- All data on-device (SQLite via sqflite).
- Persists across app restarts and updates.
- Deleted on app uninstall. No reinstall persistence required.
- No network dependency. Fully offline.
