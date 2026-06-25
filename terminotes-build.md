# Build TermiNotes Native macOS App (SQLite)

## Goal
Implement a native macOS note-taking application using SwiftUI, SQLite (native C API), and AppKit bridging with a retro terminal-styled tree sidebar and monospace editor.

## Tasks
- [x] Task 1: Create [Package.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Package.swift) → Verify: `swift build` passes configuration check.
- [x] Task 2: Create SQLite Database services [DatabaseManager.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Services/DatabaseManager.swift), [Directory.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Models/Directory.swift), and [Note.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Models/Note.swift) → Verify: Database tables initialize.
- [x] Task 3: Build state management store [AppStore.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Services/AppStore.swift) → Verify: Code compiles with no errors.
- [x] Task 4: Build [NSTextViewWrapper.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Views/NSTextViewWrapper.swift) editor component → Verify: Monospace editor compiles.
- [x] Task 5: Implement [SidebarView.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Views/SidebarView.swift) rendering retro tree and [ContentView.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/Views/ContentView.swift) layout → Verify: Navigation shell UI compiles.
- [x] Task 6: Implement [TermiNotesApp.swift](file:///Users/eldyreynanda/Developer/Antigravity/TermiNotes/Sources/TermiNotesApp.swift) app runner → Verify: `swift run` opens GUI window.

## Done When
- [x] SQLite database, sidebar lists, and editor bridge function together.
- [x] Application compiles and launches natively via `swift run`.
- [x] Note CRUD, autosaving, search, and directory collapse/expand states work.

## ✅ PHASE X COMPLETE
- Build: ✅ Success (swift build completes with exit code 0)
- Date: 2026-06-26
