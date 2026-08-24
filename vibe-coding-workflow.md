# Vibe-Coding Workflow for the Attendance App (Antigravity IDE)

## Goal

Build the app with an AI agent inside Antigravity IDE while keeping token use low. The core idea: the AI never re-reads the whole codebase to make a change. It reads a small, targeted set of markdown files that describe exactly what it needs for the current task, then edits code.

## The Doc System

Create a `/docs` folder in the project root. Keep every file short. A file that grows past a few hundred lines defeats the purpose; split it instead of letting it grow.

### 1. `docs/PROJECT.md`
Written once, at the start. Rarely changes.
- App purpose in a few lines.
- The six attendance statuses and their color codes.
- The pay-month rule (26th to 25th).
- Core features list (attendance marking, PDF export, TA/DA tracking, local login).
- Storage model: fully on-device, no cloud, no reinstall persistence.

### 2. `docs/ARCHITECTURE.md`
Updated only when the file structure or tech stack changes.
- Folder and file map of the project (one line per file, what it does).
- Tech stack: framework, local DB, PDF library.
- Data schema: tables/collections for users, attendance entries, TA/DA entries.
- Screen list with one line each: what each screen shows and which files render it.

### 3. `docs/STATE.md`
Updated at the end of every work session. This is the file that saves the most tokens, since it replaces "figure out where we left off" with a direct read.
- Current build phase.
- What is done, in one line per item.
- What is in progress, and which file(s) it touches.
- What is next.
- Any known bugs or blockers.

### 4. `docs/DECISIONS.md`
Append-only log. Add one short entry per decision, never rewrite old entries.
- Date, decision, one-line reason.
- Example: "Used SQLite over a flat JSON file for TA/DA entries, since entries are queried by day and month often."

### 5. `docs/features/*.md`
One file per feature, only read when working on that specific feature.
- `docs/features/attendance.md`: status logic, color map, calendar rendering rules.
- `docs/features/pdf-export.md`: PDF layout, legend, header fields, library used.
- `docs/features/tada.md`: entry fields, validation rules, monthly summary logic.
- `docs/features/auth.md`: login flow, device-remember logic, logout behavior.

Each feature file states its own contract: inputs, outputs, edge cases. If a task only touches TA/DA, the AI reads `PROJECT.md`, `STATE.md`, and `features/tada.md`. It does not read `pdf-export.md` or `auth.md`.

## Session Workflow

### Start of every session
1. Point the AI to read exactly three files: `PROJECT.md`, `ARCHITECTURE.md`, `STATE.md`.
2. State the task in one or two sentences.
3. Name the feature file(s) relevant to the task, so the AI reads only those, not the full `/docs/features` folder.
4. Do not paste code into the chat. Reference file paths. Let the AI open files itself through the IDE's file access, since that costs less than pasting full file contents into the prompt.

### During the session
- Keep each task scoped to one feature or one screen. Do not ask for multiple unrelated changes in one prompt; each unrelated change pulls in a different feature file and a different part of the codebase, which grows the context.
- After a change, ask the AI to summarize what changed in one or two lines. Do not ask it to re-explain the whole file.
- Avoid "review the whole app" requests. Ask instead: "check `features/tada.md` against `TadaEntryForm.tsx` for mismatches."

### End of every session
1. Update `STATE.md`: what got done, what's next, any new blockers.
2. If a decision got made (library choice, schema change, naming convention), add one line to `DECISIONS.md`.
3. If the file structure changed (new file, renamed file, new folder), update `ARCHITECTURE.md`.
4. If a feature's behavior changed, update that feature's file in `docs/features/`.

This keeps every file current, so the next session starts with a small, accurate read instead of the AI re-deriving context from the codebase.

## Build Order (Phases)

Build in this order. Each phase gets its own short session or set of sessions, and only touches its own feature file plus `ARCHITECTURE.md` and `STATE.md`.

1. **Project setup**: folder structure, tech stack install, empty screens, local DB schema. Write `PROJECT.md` and `ARCHITECTURE.md` here.
2. **Auth**: name + employee ID login, device-remember, logout. Write `features/auth.md`.
3. **Attendance marking**: calendar view, pay-month logic, status assignment, color coding. Write `features/attendance.md`.
4. **TA/DA tracking**: entry form, multiple entries per day, monthly summary. Write `features/tada.md`.
5. **PDF export**: calendar PDF generation with color legend. Write `features/pdf-export.md`.
6. **Polish**: accessibility (status labels/icons alongside color), edge cases, manual backup/export option if you decide to include it.

Do not start a phase's feature file until that phase begins. An empty `docs/features/` folder for unbuilt features keeps early sessions lighter.

## Extra Token-Saving Rules

- Never ask the AI to "read the whole project" or "look at everything" to understand context. That is exactly what the doc system replaces.
- Keep `STATE.md` as the single source of truth for "what's next." Don't ask the AI to infer progress by scanning code.
- When fixing a bug, name the exact file and the exact feature doc. Don't describe the bug and let the AI search for it.
- Close each session with the `STATE.md` update step. A session that ends without this update forces the next session to spend tokens reconstructing context.
- If a feature file or `ARCHITECTURE.md` grows long, split it rather than letting the AI read a bloated file on every related task.
