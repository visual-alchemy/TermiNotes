# Changelog

All notable changes to the **TermiNotes** project are documented in this file.

---

## [2.0.0] - 2026-06-26

This release upgrades TermiNotes to Version 2, introducing powerful developer-centric features, an optimized monospaced editing layout, tab management, drag-and-drop file organization, and real-time Markdown rendering.

### Added
* **Tab Management System**:
  * Multi-note navigation tabs using a unified state model in `AppStore` (`openTabs` and `activeTabId`).
  * Horizontal scroll overflow support on tab overflow.
  * Standard keyboard shortcuts: `Cmd+W` to close active tabs, `Cmd+Shift+[` and `Cmd+Shift+]` to switch tabs.
* **Line Numbers Gutter**:
  * Monospaced line numbers aligned to paragraph wrapping.
  * Designed to draw directly inside `EditorTextView`'s background painting pass, bypassing NSRulerView rendering bugs.
  * Toggled via `Cmd+L`.
* **GitHub-Style Markdown Preview**:
  * WebKit-backed preview mode rendering notes via custom GitHub stylesheet rules.
  * Integrated SPM package dependency for `Ink` to handle HTML parsing.
  * Toggled via `Cmd+R` or the header action buttons.
* **Inline Syntax Highlighting**:
  * Real-time regex highlighting inside the editor (headings, bold, italic, lists, code spans, blockquotes, horizontal rules).
* **Sidebar Drag-and-Drop**:
  * Notes can be dragged and dropped into folders to organize them.
* **Delete Confirmation Prompts**:
  * Confirmation alerts for file and folder deletions (recursively showing counts of child notes that will be removed).
* **Status Bar**:
  * Monospaced stats showing active line, column, word count, and character counts.
* **Markdown Export**:
  * Export notes using `Cmd+E` via a native save panel (suggestions include filename sanitization to replace `/` and `:` characters).

### Fixed
* **Sidebar Resize**: Fixed layouts constraint conflicts on sidebar width values.
* **Editor Bleed**: Fixed an issue where changing tabs caused content of the previous note to bleed into the new one (updated representable delegate coordinator references).
* **Cursor Jumping**:
  * Fixed an issue where the editor cursor jumped to the end of the document on every keystroke by mapping bindings directly to the Observable `store.activeNote` rather than a captured copy of the `Note` struct.
  * Fixed selection resetting and layout corruption (automatic newlines) during typing by moving the text storage delegate hook to `didProcessEditing` and restricting attribute changes to only the paragraph range intersecting the edit.
