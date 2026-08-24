# Architecture

## Tech Stack
| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.47.1 (Dart 3.13.1) |
| Local DB | sqflite + path_provider |
| State | Riverpod (flutter_riverpod) |
| PDF | pdf + printing |
| CSV | csv |
| Share | share_plus |
| Auth persistence | shared_preferences |
| Fonts | google_fonts (Inter) |

## Folder Map
```
lib/
├── main.dart                        # Entry point, DB init, ProviderScope
├── app.dart                         # MaterialApp, theme, auth gate (splash → login/home)
├── theme/
│   └── app_theme.dart               # Dark theme, color palette, component themes
├── models/
│   ├── user.dart                    # User data class
│   ├── attendance_entry.dart        # Attendance entry with status + date
│   └── tada_entry.dart              # TA/DA expense entry
├── database/
│   └── database_helper.dart         # SQLite singleton, schema, CRUD operations
├── providers/
│   ├── auth_provider.dart           # Login/logout, auto-login via SharedPrefs
│   ├── attendance_provider.dart     # Attendance CRUD, pay-month loading
│   └── tada_provider.dart           # TA/DA CRUD, monthly + daily loading
├── screens/
│   ├── login_screen.dart            # Name + employee ID form
│   ├── home_screen.dart             # Bottom nav (Attendance/TA-DA), profile menu
│   ├── attendance_screen.dart       # Calendar grid, status picker, PDF export
│   ├── tada_screen.dart             # Day TA/DA entries, add/edit/delete
│   └── tada_summary_screen.dart     # Monthly TA/DA summary, CSV/PDF export
├── widgets/
│   ├── calendar_widget.dart         # 7-column calendar grid with colored day cells
│   ├── status_picker.dart           # 6-status chip selector
│   ├── color_legend.dart            # Status color legend
│   └── tada_entry_card.dart         # Single TA/DA entry display
└── utils/
    ├── constants.dart               # AttendanceStatus enum, colors, labels, icons
    ├── pay_month.dart               # 26th–25th pay-month logic, navigation
    ├── pdf_generator.dart           # Attendance calendar PDF generation
    └── tada_export.dart             # TA/DA CSV + PDF export
```

## Data Schema
### users
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Employee name |
| employee_id | TEXT UNIQUE | Employee ID |

### attendance
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| user_id | INTEGER FK | → users.id |
| date | TEXT | ISO yyyy-MM-dd |
| status | TEXT | Enum name |
| | | UNIQUE(user_id, date) |

### tada_entries
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| user_id | INTEGER FK | → users.id |
| date | TEXT | ISO yyyy-MM-dd |
| purpose | TEXT | Expense purpose |
| amount | REAL | Amount in currency |
| remarks | TEXT | Optional notes |

## Screen List
| Screen | Shows | Files |
|--------|-------|-------|
| Login | Name + ID form, auto-login check | login_screen.dart, auth_provider.dart |
| Home | Bottom nav, profile menu | home_screen.dart |
| Attendance | Calendar, status picker, legend, PDF export | attendance_screen.dart, calendar_widget.dart |
| TA/DA Day | Entry list for a day, add/edit/delete | tada_screen.dart, tada_entry_card.dart |
| TA/DA Summary | Monthly entries grouped by date, CSV/PDF export | tada_summary_screen.dart |
