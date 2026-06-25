# TermiNotes AI Agents and Roles History

This document lists the specialist AI agents and skills utilized during the development and implementation of the **TermiNotes v2 Upgrade** session.

---

## 🤖 Active Agent Directory

### 1. `project-planner`
* **Role**: Lead Architect & Task Coordinator
* **Phase Utilized**: Session Start & Phase 2 Planning
* **Contribution**: 
  * Analyzed the v2 specification requirements.
  * Formulated the architectural plans and created the milestone-driven task breakdown.
  * Authored the initial implementation spec.

### 2. `frontend-specialist` (Primary)
* **Role**: Senior UI/UX & AppKit-SwiftUI Bridge Engineer
* **Phase Utilized**: Core Implementation & Final Debugging Phases
* **Contribution**:
  * Designed and built the SwiftUI custom tab system (`TabBarView` and `TabItemView`).
  * Implemented the custom line number rendering system inside `EditorTextView`'s background painting routine to prevent zero-frame layout loops.
  * Designed the GitHub-style HTML/CSS preview render system wrapping WebKit's `WKWebView`.
  * Resolved the typing cursor-jump state synchronization loops and paragraph-restricted highlighting rules.

### 3. `debugger`
* **Role**: Systems & Runtime Debugging Specialist
* **Phase Utilized**: Active Bug Investigation Phases
* **Contribution**:
  * Isolated multi-note rendering bleed bugs.
  * Analyzed Cocoa text system rendering issues, identifying the invalidation loop between `NSTextStorage` attributes and selection ranges.
  * Corrected the delegate hook from `willProcessEditing` to `didProcessEditing`.

---

## 🧰 Custom Skills Applied

* **`clean-code`**: Applied production-grade, self-documenting Swift code patterns, avoiding over-abstractions, and writing clean, localized highlighter logic.
* **`brainstorming`**: Adhered to the Socratic Gate guidelines, validating requirements, layout behaviors, and trade-offs before implementation.
* **`verification-before-completion`**: Verified all compilation, execution, and visual states locally before staging, committing, and closing issues.
