# Decisions

## 2026-08-24
- **Flutter over React Native** — Flutter is installed (3.47.1), single codebase, strong PDF/SQLite ecosystem.
- **sqflite for local storage** — Structured queries by date range needed for attendance and TA/DA; SQLite is ideal.
- **Riverpod for state management** — Lightweight, compile-safe, no boilerplate (Provider is deprecated, Bloc is heavy for this scope).
- **pdf + printing packages** — Pure Dart PDF generation, no native bridge; printing package handles share/print/preview.
- **share_plus for CSV export** — Standard Flutter file sharing via system share sheet.
- **google_fonts (Inter)** — Clean, modern sans-serif for a premium app feel.
- **Dark theme only** — Premium aesthetic, simpler implementation. Light theme can be added later if requested.
- **SharedPreferences for auth persistence** — Simple key-value store for user ID; survives restarts, cleared on uninstall.
- **Taka (৳) as currency symbol** — Based on the user's locale (Bangladesh).
- **Date stored as ISO string** — `yyyy-MM-dd` format enables range queries and sorting in SQLite.
