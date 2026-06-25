# TermiNotes PRD & Tech Stack

## Product Overview

**Product name:** TermiNotes  
**Tagline:** Notes supposed to be simple.

TermiNotes is a native macOS note-taking application designed around a terminal-like user experience. The product combines the familiarity of filesystem navigation with a minimal writing environment, allowing users to organize notes into directory-style groups such as Work, Personal, Secrets, and Recipes while editing content in a distraction-free monospace interface.[cite:2][cite:5]

The product vision is to make note-taking feel like working inside a clean developer tool rather than a conventional productivity app. The terminal aesthetic is used as a visual system and interaction metaphor, not as a requirement for users to type commands in order to use the app.[cite:5]

## Problem Statement

Most note apps are either visually busy, overly feature-heavy, or optimized for generic mass-market use. Users who prefer technical tools, keyboard-centric workflows, and structured organization often lack a note app that feels as focused and familiar as a terminal or file explorer while still remaining approachable for everyday note-taking.[cite:2][cite:5]

TermiNotes addresses this gap by offering:
- A directory-and-file mental model for note organization.
- A terminal-inspired writing and browsing experience.
- A native macOS interface with resizable panels and minimal chrome.
- Simple local-first note capture without unnecessary complexity.[cite:2][cite:3]

## Goals

### Product Goals

- Deliver a note-taking experience that feels native to macOS and optimized for Apple Silicon devices.[cite:3]
- Preserve simplicity in both interface and feature set while maintaining enough structure for real daily use.[cite:2]
- Create a clear identity around terminal-style aesthetics and filesystem-based note organization.[cite:5]
- Support fast note creation, browsing, editing, and retrieval with low friction.

### User Goals

- Quickly create and edit notes.
- Organize notes into meaningful top-level directories.
- Resize the sidebar based on browsing needs.
- Navigate comfortably with keyboard and mouse/trackpad.
- Maintain focus inside a distraction-free editor.

## Non-Goals

The initial version of TermiNotes will not include:
- Cross-platform support outside macOS.
- Real-time collaboration.
- Cloud sync or multi-device sync.
- Rich text document editing.
- Full command-line input as the primary UX model.
- Plugin architecture in the MVP.

## Target Users

### Primary Users

- Developers, technical operators, and power users who are comfortable with terminal metaphors and file-based organization.[cite:5]
- macOS users who want a simple local note app that feels closer to a developer utility than a traditional notebook UI.[cite:2][cite:3]

### Secondary Users

- Users who prefer plain text or Markdown notes.
- Users who manage separate note categories such as work, personal life, private information, recipes, snippets, and logs.[file:6]

## Core Experience

TermiNotes opens into a two-pane interface. The left pane is a resizable sidebar that displays note directories and note files in a tree structure. The right pane is a terminal-like editor view that prioritizes legibility, focus, and keyboard-friendly editing.[file:6]

The sidebar uses a filesystem-inspired visual language:
- Directories are shown as expandable groups, for example `> Work/` or `> Personal/`.[file:6]
- Notes appear as child items using tree connectors such as `├─` and `└─`.
- The selected note receives a subtle highlight.
- The divider between sidebar and editor can be dragged to resize the browsing area.[file:6]

The editor uses a monospace presentation with minimal chrome and a dark theme. It should feel like a hybrid of a code editor, terminal, and plain-text notebook rather than a rich document editor.[cite:5][file:6]

## Information Architecture

### Entity Model

#### Workspace
A local storage container for all notes and directory metadata.

#### Directory
A top-level or nested grouping unit used to separate note categories such as Work, Personal, Secrets, or Recipes.[file:6]

Suggested directory fields:
- `id`
- `name`
- `parentDirectoryId` (nullable)
- `sortOrder`
- `createdAt`
- `updatedAt`
- `isCollapsed`

#### Note
A text-based document stored inside a directory.

Suggested note fields:
- `id`
- `directoryId`
- `title`
- `slug`
- `content`
- `format` (plain text or Markdown)
- `createdAt`
- `updatedAt`
- `isPinned`
- `isArchived`

## MVP Features

### 1. Local-first Notes
- Create a note.
- Open a note.
- Edit and autosave a note.
- Rename a note.
- Delete a note.

### 2. Directory Tree Navigation
- Create directories.
- Rename directories.
- Collapse and expand directories.
- Move notes between directories.
- Display notes under their parent directory using a tree view.[file:6]

### 3. Resizable Sidebar
- Drag the divider between sidebar and editor.
- Persist sidebar width across app launches.
- Enforce min and max sidebar widths to preserve usability.[file:6]

### 4. Terminal-like Editor
- Monospace typography.
- Dark theme by default.
- Plain writing canvas with minimal distractions.
- Optional Markdown syntax support in raw text mode.

### 5. Search
- Search note titles and note bodies.
- Filter results while preserving directory context where possible.

### 6. Keyboard Shortcuts
- New note.
- New directory.
- Focus search.
- Toggle sidebar.
- Delete selected note.
- Navigate tree items with arrow keys.

## Future Features

- Global command palette.
- Quick switcher.
- Tags as a secondary classification layer.
- Note pinning and favorites.
- Export to Markdown or text files.
- Optional iCloud or custom sync.
- Vim-style keybindings.
- Inline preview mode.
- Encryption for private directories such as Secrets.

## Functional Requirements

### Notes
- The system must allow users to create, edit, rename, and delete notes.
- The system must autosave note content locally.
- The system must associate each note with a directory.
- The system should support plain text at minimum and may support Markdown in the MVP.

### Directories
- The system must allow users to create, rename, delete, collapse, and expand directories.
- The system must visually render directories and notes in a hierarchical tree.[file:6]
- The system must support multiple semantic categories such as work, personal, secrets, and recipes.[file:6]

### Layout
- The system must render a two-pane desktop layout with a left sidebar and right editor.[file:6]
- The system must support drag resizing of the sidebar.[file:6]
- The system must preserve window and sidebar layout state across launches.

### Editor
- The system must display note content in a terminal-like editor area using monospace typography.
- The system must support large note editing without major performance issues.
- The system should preserve cursor position on reopen when feasible.

### Search and Navigation
- The system must provide local full-text search.
- The system must support keyboard navigation across directories and notes.
- The system should allow quick navigation without relying solely on the pointer.

## Non-Functional Requirements

- Native performance on Apple Silicon Macs, including M-series devices.[cite:3]
- Fast app launch and low idle memory usage.
- Works fully offline.
- Reliable local persistence.
- High readability in dark mode.
- Accessible keyboard navigation for primary flows.

## UX Principles

- **Terminal as language, not barrier:** the app should look technical without forcing users to learn commands.[cite:5]
- **Structure over clutter:** directories and notes should remain visually legible even as the tree grows.
- **Fast by default:** creating or opening a note should take minimal interaction.
- **Quiet interface:** low-chrome, low-distraction, high-focus editing.
- **Native feel:** scrolling, resizing, selection, focus, and shortcuts should behave like a proper macOS app.

## Success Metrics

### Qualitative
- Users understand the directory-based note model without explanation.
- Users describe the app as simple, fast, and “terminal-like” rather than gimmicky.
- Users can distinguish categories such as Work, Personal, and Secrets naturally through directories.[file:6]

### Quantitative
- Time to first note created: under 30 seconds from first launch.
- App cold launch: under 2 seconds on Apple Silicon target devices.
- Sidebar resize interaction completes smoothly with no visible lag.
- Search results begin appearing within 100 ms for normal local datasets.

## Suggested Release Scope

### Milestone 1: Foundation
- Borderless or low-chrome macOS window
- Two-pane layout
- Resizable sidebar
- Local persistence
- Note CRUD
- Directory CRUD

### Milestone 2: Productivity
- Search
- Keyboard shortcuts
- Improved selection and tree navigation
- Sidebar width persistence

### Milestone 3: Polish
- Better onboarding/empty states
- Optional Markdown enhancements
- Export and import
- Theme refinements

## Tech Stack Recommendation

### Primary Recommendation

#### Language
- **Swift** for the full application codebase.

#### UI Layer
- **SwiftUI** for most application layout and state-driven views.
- **AppKit bridging** for advanced macOS window customization and specific controls that need deeper native behavior.

This combination is the best fit because the product is macOS-only, requires native desktop behavior, and benefits from deep integration with Apple UI patterns and system performance characteristics.[cite:3]

### Windowing and Layout
- **NSWindow** customization through AppKit for borderless or minimal-chrome window behavior.
- **NSSplitView** or a SwiftUI wrapper around split-view behavior for a resizable sidebar with macOS-native dragging.

A split-view-based implementation is the most reliable way to reproduce the adjustable left sidebar shown in the concept while keeping resizing behavior native and stable.[file:6]

### Sidebar Tree
- **NSOutlineView** via AppKit bridge for the directory-and-note tree.

Although SwiftUI offers `OutlineGroup`, `NSOutlineView` is the stronger long-term choice if the product needs precise control over hierarchical rendering, keyboard navigation, selection styling, collapse behavior, and tree connector visuals similar to the concept image.[file:6]

### Editor
- **NSTextView** wrapped for SwiftUI integration.

This is recommended over a basic SwiftUI `TextEditor` because the editor needs stronger control over typography, selection behavior, performance on long documents, text attributes, and terminal-like editing presentation.

### Persistence
Choose one of these approaches:

| Option | Recommendation | Reason |
|---|---|---|
| SwiftData | Good for rapid native development | Integrates well with SwiftUI and modern Apple APIs |
| SQLite | Strong long-term control | Better for explicit schema evolution, indexing, and predictable local storage |

Recommended path:
- Start with **SQLite** if the product is expected to grow in complexity, especially for search, migration, and future export/import flows.
- Start with **SwiftData** if the immediate priority is speed of development for an MVP.

### Search
- SQLite FTS (Full-Text Search) if SQLite is chosen.
- Native in-memory indexing for small datasets in early MVP builds.

### File Format
- Internal storage can be database-backed.
- Export format should be `.md` or `.txt`.
- Notes should remain text-first and portable.

### Architecture Pattern
- **MVVM** for UI state separation.
- A dedicated persistence layer or repository abstraction for notes and directories.
- A lightweight service layer for search, autosave, and import/export.

Suggested module boundaries:
- `App`
- `Window`
- `SidebarTree`
- `Editor`
- `Persistence`
- `Search`
- `Shortcuts`
- `Theme`

### Styling
- Monospace typography, for example SF Mono, JetBrains Mono, or IBM Plex Mono.
- Dark-first theme.
- Minimal separators and subtle active-state highlights.
- Low-chrome native macOS presentation.

### Platform Target
- macOS 14+ is a practical target if using modern SwiftUI and SwiftData APIs.
- Universal binary for Apple Silicon and Intel can be considered, but Apple Silicon should be the primary optimization target.[cite:3]

## Why This Stack Fits

This stack fits TermiNotes because the product is explicitly macOS-native, terminal-inspired, and desktop-first. SwiftUI provides rapid UI composition, while AppKit fills the gaps for precision desktop behaviors such as tree navigation, native split resizing, and advanced editor control.[cite:2][cite:3][file:6]

Using web technologies such as Electron or heavier cross-platform layers would likely add overhead and reduce the native feel of resizing, focus management, text editing, and window presentation, all of which are central to the product identity. A native stack better supports the app's promise of simplicity, speed, and a developer-tool aesthetic.[cite:2][cite:5]
