import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(AppStore.self) private var store
    
    @AppStorage("sidebarWidth") private var sidebarWidth: Double = 240.0
    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
    @State private var isSidebarVisible = true
    @State private var cursorPosition: Int = 0
    @State private var isPreviewMode = false
    
    // Dialog triggers
    @State private var showingAddDirectory = false
    @State private var newDirectoryName = ""
    @State private var showingAddNote = false
    @State private var newNoteTitle = ""
    @State private var targetDirectory: Directory? = nil
    
    // Delete confirmation
    @State private var showingDeleteNoteConfirm = false
    @State private var deleteNoteTarget: Note? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            if isSidebarVisible {
                SidebarView()
                    .frame(width: CGFloat(sidebarWidth))
                
                // Draggable Divider Line
                Rectangle()
                    .fill(Color(nsColor: NSColor.gridColor))
                    .frame(width: 1)
                    .onHover { inside in
                        if inside {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { gesture in
                                let newWidth = gesture.location.x
                                if newWidth >= 180 && newWidth <= 400 {
                                    sidebarWidth = newWidth
                                }
                            }
                    )
            }
            
            // Main Editor Pane
            if let note = store.activeNote {
                VStack(spacing: 0) {
                    // Path Bar / Header
                    HStack {
                        let dirName = store.directories.first(where: { $0.id == note.directoryId })?.name ?? "UNGROUPED"
                        Text("\(dirName) / \(note.title)")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("UPDATED: \(note.updatedAt, style: .time)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                        
                        Button(action: {
                            isPreviewMode.toggle()
                        }) {
                            Text(isPreviewMode ? "✏️ EDIT" : "📄 PREVIEW")
                                .font(.system(.caption, design: .monospaced, weight: .bold))
                                .foregroundColor(isPreviewMode ? .white : Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(nsColor: NSColor(red: 0.16, green: 0.20, blue: 0.25, alpha: 1.0)))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
                    .border(Color(nsColor: NSColor.gridColor), width: 1)
                    
                    // Tab Bar
                    if !store.openTabs.isEmpty {
                        TabBarView()
                        Divider()
                    }
                    
                    // Editor / Preview view
                    if isPreviewMode {
                        MarkdownPreviewView(markdown: note.content)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        NSTextViewWrapper(
                            text: Binding(
                                get: { store.activeNote?.content ?? "" },
                                set: { store.updateNoteContent(noteId: note.id, content: $0) }
                            ),
                            cursorPosition: $cursorPosition,
                            showLineNumbers: showLineNumbers
                        )
                    }
                    
                    // Status Bar
                    StatusBarView(text: note.content, cursorPosition: cursorPosition)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
            } else {
                // Monospace Empty State
                VStack(spacing: 16) {
                    Text("TERMINOTES v1.0.0")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)))
                    
                    Text("Notes supposed to be simple.")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    Text("Create a folder and note inside it to begin.")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        // Background Command Handlers (Keyboard Shortcuts)
        .background(
            Group {
                // Cmd + \ (Toggle Sidebar)
                Button("") {
                    isSidebarVisible.toggle()
                }
                .keyboardShortcut("\\", modifiers: [.command])
                .opacity(0)
                
                // Cmd + Shift + N (New Directory)
                Button("") {
                    newDirectoryName = ""
                    showingAddDirectory = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .opacity(0)
                
                // Cmd + N (New Note in active directory)
                Button("") {
                    if let activeNote = store.activeNote,
                       let activeDir = store.directories.first(where: { $0.id == activeNote.directoryId }) {
                        targetDirectory = activeDir
                    } else {
                        targetDirectory = store.directories.first
                    }
                    
                    if targetDirectory != nil {
                        newNoteTitle = ""
                        showingAddNote = true
                    } else {
                        newDirectoryName = ""
                        showingAddDirectory = true
                    }
                }
                .keyboardShortcut("n", modifiers: [.command])
                .opacity(0)
                
                // Cmd + Backspace (Delete Active Note with confirmation)
                Button("") {
                    if let note = store.activeNote {
                        deleteNoteTarget = note
                        showingDeleteNoteConfirm = true
                    }
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                .opacity(0)
                
                // Cmd + W (Close Active Tab)
                Button("") {
                    store.closeActiveTab()
                }
                .keyboardShortcut("w", modifiers: [.command])
                .opacity(0)
                
                // Cmd + Shift + [ (Previous Tab)
                Button("") {
                    store.switchToPreviousTab()
                }
                .keyboardShortcut("[", modifiers: [.command, .shift])
                .opacity(0)
                
                // Cmd + Shift + ] (Next Tab)
                Button("") {
                    store.switchToNextTab()
                }
                .keyboardShortcut("]", modifiers: [.command, .shift])
                .opacity(0)
                
                // Cmd + L (Toggle Line Numbers)
                Button("") {
                    showLineNumbers.toggle()
                }
                .keyboardShortcut("l", modifiers: [.command])
                .opacity(0)
                
                // Cmd + E (Export as .md)
                Button("") {
                    exportActiveNote()
                }
                .keyboardShortcut("e", modifiers: [.command])
                .opacity(0)
                
                // Cmd + R (Toggle Preview Mode)
                Button("") {
                    isPreviewMode.toggle()
                }
                .keyboardShortcut("r", modifiers: [.command])
                .opacity(0)
            }
        )
        // Delete Note Confirmation
        .alert("Delete \"\(deleteNoteTarget?.title ?? "")\"?", isPresented: $showingDeleteNoteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let note = deleteNoteTarget {
                    store.deleteNote(note)
                }
            }
        } message: {
            Text("This note will be permanently deleted. This cannot be undone.")
        }
        // Add Directory Popover Sheet
        .sheet(isPresented: $showingAddDirectory) {
            VStack(spacing: 16) {
                Text("NEW DIRECTORY")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Folder Name", text: $newDirectoryName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                HStack {
                    Button("Cancel") {
                        showingAddDirectory = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Create") {
                        if !newDirectoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.addDirectory(name: newDirectoryName)
                            showingAddDirectory = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 280)
        }
        // Add Note Popover Sheet
        .sheet(isPresented: $showingAddNote) {
            VStack(spacing: 16) {
                Text("NEW NOTE")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Note Name (e.g. log.md)", text: $newNoteTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                HStack {
                    Button("Cancel") {
                        showingAddNote = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Create") {
                        if !newNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                           let directory = targetDirectory {
                            store.addNote(title: newNoteTitle, directoryId: directory.id)
                            showingAddNote = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 280)
        }
    }
    
    // MARK: - Export
    
    private func exportActiveNote() {
        guard let note = store.activeNote else { return }
        
        let panel = NSSavePanel()
        panel.title = "Export Note as Markdown"
        
        let sanitizedTitle = note.title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        panel.nameFieldStringValue = sanitizedTitle
        
        panel.allowedContentTypes = [UTType.plainText]
        panel.canCreateDirectories = true
        
        if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            panel.directoryURL = docsURL
        }
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? note.content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
