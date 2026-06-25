# TermiNotes v2 Upgrade Design Specification

* **Date:** 2026-06-26
* **Status:** Approved
* **Builds on:** [TermiNotes v1 Design](./2026-06-26-terminotes-design.md)

---

## 1. Overview

This spec covers all features needed to bring TermiNotes from its current working prototype to a public-release-quality application. The `.app` bundling and icon integration are explicitly **deferred** — the user will trigger that step manually after testing all features via `swift run`.

### Target Audience
Public release (GitHub open source, potentially Mac App Store).

### Feature Summary

| # | Feature | Category |
|---|---------|----------|
| 1 | Tab system with close buttons | Core UX |
| 2 | Delete confirmation dialogs | Core UX |
| 3 | Drag-and-drop notes between folders | Core UX |
| 4 | Editor status bar (line, col, words, chars) | Core UX |
| 5 | Inline Markdown syntax highlighting | Editor Power |
| 6 | Line numbers gutter | Editor Power |
| 7 | Export note as `.md` file | Editor Power |

---

## 2. Tab System

### Data Model Changes

`AppStore` gains:
- `openTabs: [Note]` — ordered list of currently open notes (by open order)
- `activeTabId: UUID?` — the currently focused tab (replaces the existing `selectedNote` concept)
- Computed `activeNote: Note?` — resolves `activeTabId` against `openTabs`

The existing `selectedNote` property is removed and replaced by the tab-based selection.

### State Management

| Action | Result |
|--------|--------|
| Click note in sidebar | Opens tab (if not already open) and switches to it |
| Click a tab | Switches active tab |
| Click `×` on tab | Closes that tab; if it was active, switches to the nearest remaining tab |
| `Cmd+W` | Closes the active tab |
| `Cmd+Shift+[` | Switch to previous tab |
| `Cmd+Shift+]` | Switch to next tab |
| Delete note (sidebar) | Removes the tab if it was open |
| Rename note (sidebar) | Updates the tab title live (both reference the same `Note` by ID) |
| All tabs closed | Show empty state ("TERMINOTES v1.0.0") |

### Tab Bar UI

- Horizontal bar between the path header and the editor area
- Monospace font, dark background matching the path header (`NSColor(red: 0.06, green: 0.08, blue: 0.10)`)
- Active tab: green text (`NSColor(red: 0.24, green: 0.98, blue: 0.34)`), subtle bottom border highlight
- Inactive tabs: gray text, no highlight
- `×` close button appears on hover per tab (small, monospace `×` glyph)
- Tabs scroll horizontally if they overflow the available width

---

## 3. Delete Confirmation Dialogs

All destructive actions require explicit user confirmation via a native macOS `.alert`:

### Delete Note
- Title: `"Delete "\(note.title)"?"`
- Message: `"This note will be permanently deleted. This cannot be undone."`
- Buttons: **Cancel** (default), **Delete** (destructive)

### Delete Folder
- Title: `"Delete "\(directory.name)"?"`
- Message: `"This folder and all \(noteCount) note(s) inside it will be permanently deleted. This cannot be undone."`
- Buttons: **Cancel** (default), **Delete** (destructive)

Applied in:
- Context menu "Delete Note" / "Delete Folder" actions in `SidebarView`
- `Cmd+Backspace` shortcut in `ContentView`

---

## 4. Drag-and-Drop Notes Between Folders

### Interaction
- Notes in the sidebar tree are draggable (using SwiftUI `.draggable` / `.onDrag`)
- Directory header rows act as drop targets (using `.dropDestination` / `.onDrop`)
- Dragging a note onto a different folder header reassigns its `directoryId`

### Visual Feedback
- When a valid drop target is hovered, the folder header row background tints to a subtle green highlight
- Invalid drops (e.g., dropping onto the same parent folder) are ignored

### Data Flow
1. User drags note from Folder A
2. Drops onto Folder B header
3. `AppStore.moveNote(_ note: Note, to directoryId: UUID)` is called
4. In-memory array updated, `DatabaseManager.updateNote()` persists the change
5. If the note is in an open tab, the tab's path header updates to reflect the new parent folder

---

## 5. Editor Status Bar

### Layout
A thin horizontal bar pinned to the bottom of the editor pane (below the text view, above the window edge).

### Content
Monospace gray text showing cursor and document statistics:

```
Ln 12, Col 34  |  256 words  |  1,482 chars
```

### Behavior
- **Line and column**: Updated on every cursor position change (via `NSTextView` selection change notification)
- **Word and character count**: Updated on every text change (debounced to avoid performance hits on large documents)
- Background color matches the path header: `NSColor(red: 0.06, green: 0.08, blue: 0.10)`
- Text color: `.gray` monospace

### Data Source
- Cursor position: computed from `NSTextView.selectedRange()` by counting newlines before the cursor
- Word count: `text.split(whereSeparator: \.isWhitespace).count`
- Character count: `text.count`

---

## 6. Inline Markdown Syntax Highlighting

### Architecture
A custom `NSTextStorageDelegate` (or subclass) that re-attributes text after each edit pass. This runs on the main thread but is scoped to the edited paragraph range for performance.

### Highlighting Rules

All text remains **monospace** (Menlo/SF Mono). Only color, weight, and background change:

| Markdown Element | Visual Treatment |
|-----------------|-----------------|
| `# Heading 1` | Bold + green accent (`0.24, 0.98, 0.34`) + larger size (16pt) |
| `## Heading 2` | Bold + green accent + slightly larger (15pt) |
| `### Heading 3+` | Bold + green accent (same 13pt base size) |
| `**bold text**` | Bold weight (same color) |
| `*italic text*` | Italic style (same color) |
| `` `inline code` `` | Background tint (`NSColor(red: 0.14, green: 0.17, blue: 0.21)`) |
| ```` ```code block``` ```` | Same background tint, slightly dimmed text color |
| `- list item` / `* list item` | Green color on the bullet character only |
| `> blockquote` | Dimmed gray text color (`0.5, 0.5, 0.55`) |
| `[text](url)` | Blue underline on `text`, gray on brackets/URL |
| `---` / `***` (horizontal rule) | Dimmed gray |

### Regex Patterns
Each rule is a compiled `NSRegularExpression` stored as a static property for performance. Patterns are applied in priority order (code blocks first to prevent inner matches, then headers, then inline elements).

### Performance
- Only re-highlight the affected paragraph range on each edit (not the full document)
- Use `NSTextStorage.processEditing()` to apply attributes during the editing cycle
- Benchmark target: no perceptible lag on documents up to 10,000 lines

---

## 7. Line Numbers Gutter

### Layout
A narrow vertical column (approximately 40pt wide) on the left edge of the editor, inside the scroll view.

### Implementation
A custom `NSRulerView` subclass added to the `NSScrollView` as a vertical ruler. It reads the text layout manager to determine visible line ranges and draws line numbers in monospace gray text, right-aligned.

### Behavior
- Scrolls in sync with the text view (automatic via ruler view attachment)
- Line numbers are 1-indexed
- Current cursor line number is highlighted in white (others remain gray)
- Toggle visibility via `Cmd+L` keyboard shortcut
- Default state: visible

---

## 8. Export as .md File

### Trigger
- Keyboard shortcut: `Cmd+E`
- Menu bar: File → Export as Markdown... (when menu bar is implemented in Phase 3)

### Behavior
1. If no note is active, do nothing
2. Open a native `NSSavePanel`
3. Pre-fill filename with the note's title (e.g., `todo.md`)
4. Default directory: user's Documents folder
5. Write the note's raw `content` string as UTF-8 text
6. No Markdown rendering — exports the source text exactly as stored

---

## 9. Keyboard Shortcuts Summary

| Shortcut | Action |
|----------|--------|
| `Cmd+N` | New note in active/first directory |
| `Cmd+Shift+N` | New directory |
| `Cmd+W` | Close active tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+Shift+]` | Next tab |
| `Cmd+\` | Toggle sidebar |
| `Cmd+Backspace` | Delete active note (with confirmation) |
| `Cmd+L` | Toggle line numbers |
| `Cmd+E` | Export active note as .md |
| `Cmd+F` | Focus search bar |

---

## 10. Implementation Order

Features are ordered by dependency and risk:

1. **Tab system** — foundational change, everything else builds on it
2. **Delete confirmations** — small, isolated, quick win
3. **Status bar** — independent of other features
4. **Drag-and-drop** — requires sidebar changes but no editor changes
5. **Line numbers gutter** — editor-side, independent of highlighting
6. **Inline Markdown highlighting** — most complex, benefits from stable editor
7. **Export as .md** — simplest feature, saved for last

---

## 11. Verification Plan

### Build Check
```bash
swift build
swift run
```

### Manual Testing Matrix

| Test | Expected Result |
|------|----------------|
| Open 3 notes, switch between tabs | Correct content in each tab, cursor position preserved |
| Close middle tab with `×` | Tab removed, adjacent tab becomes active |
| `Cmd+W` with one tab open | Tab closes, empty state shown |
| Right-click delete note | Confirmation dialog appears, cancel preserves note |
| Drag note from Folder A to Folder B | Note moves, sidebar updates, tab path header updates |
| Type Markdown in editor | Headers turn green+bold, code gets background tint |
| Scroll long document | Line numbers scroll in sync, status bar updates |
| `Cmd+E` on active note | Save dialog opens, file exports correctly |
| `Cmd+L` toggle | Line numbers appear/disappear |
