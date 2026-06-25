import SwiftUI

struct SidebarView: View {
    @Environment(AppStore.self) private var store
    
    // Dialog states
    @State private var showingAddDirectory = false
    @State private var newDirectoryName = ""
    
    @State private var showingAddNote = false
    @State private var newNoteTitle = ""
    @State private var targetDirectory: Directory?
    
    @State private var showingRenameDirectory = false
    @State private var renameDirectoryTarget: Directory?
    @State private var renameDirectoryName = ""
    
    @State private var showingRenameNote = false
    @State private var renameNoteTarget: Note?
    @State private var renameNoteTitle = ""
    
    // Delete confirmations
    @State private var showingDeleteDirConfirm = false
    @State private var deleteDirTarget: Directory?
    @State private var showingDeleteNoteConfirm = false
    @State private var deleteNoteTarget: Note?
    
    var body: some View {
        @Bindable var storeBindable = store
        
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search notes...", text: $storeBindable.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(10)
            .background(Color(nsColor: NSColor(red: 0.16, green: 0.20, blue: 0.25, alpha: 1.0)))
            .cornerRadius(6)
            .padding([.horizontal, .top], 10)
            
            // Sidebar List / Tree
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if store.searchText.isEmpty {
                        if store.directories.isEmpty {
                            Text("No folders yet. Click '+' below.")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(store.directories) { directory in
                                DirectorySectionView(
                                    directory: directory,
                                    onAddNote: {
                                        targetDirectory = directory
                                        showingAddNote = true
                                    },
                                    onRenameDirectory: { dir in
                                        renameDirectoryTarget = dir
                                        renameDirectoryName = dir.name
                                        showingRenameDirectory = true
                                    },
                                    onRenameNote: { note in
                                        renameNoteTarget = note
                                        renameNoteTitle = note.title
                                        showingRenameNote = true
                                    },
                                    onDeleteDirectory: { dir in
                                        deleteDirTarget = dir
                                        showingDeleteDirConfirm = true
                                    },
                                    onDeleteNote: { note in
                                        deleteNoteTarget = note
                                        showingDeleteNoteConfirm = true
                                    }
                                )
                            }
                        }
                    } else {
                        SearchResultsView(
                            onRenameNote: { note in
                                renameNoteTarget = note
                                renameNoteTitle = note.title
                                showingRenameNote = true
                            },
                            onDeleteNote: { note in
                                deleteNoteTarget = note
                                showingDeleteNoteConfirm = true
                            }
                        )
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: NSColor(red: 0.08, green: 0.11, blue: 0.14, alpha: 1.0)))
            
            // Sidebar Footer Actions
            HStack {
                Button(action: {
                    newDirectoryName = ""
                    showingAddDirectory = true
                }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                        .font(.system(.caption, design: .monospaced))
                }
                .buttonStyle(.plain)
                .foregroundColor(.gray)
                .help("Create a new directory (Cmd+Shift+N)")
                
                Spacer()
            }
            .padding(12)
            .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: NSColor(red: 0.08, green: 0.11, blue: 0.14, alpha: 1.0)))
        // Delete Directory Confirmation
        .alert("Delete \"\(deleteDirTarget?.name ?? "")\"?", isPresented: $showingDeleteDirConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let dir = deleteDirTarget {
                    store.deleteDirectory(dir)
                }
            }
        } message: {
            let noteCount = deleteDirTarget.map { dir in store.notesForDirectory(dir.id).count } ?? 0
            Text("This folder and all \(noteCount) note(s) inside it will be permanently deleted. This cannot be undone.")
        }
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
        // Add Directory Popover
        .sheet(isPresented: $showingAddDirectory) {
            VStack(spacing: 16) {
                Text("NEW DIRECTORY")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Directory Name", text: $newDirectoryName)
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
        // Add Note Popover
        .sheet(isPresented: $showingAddNote) {
            VStack(spacing: 16) {
                Text("NEW NOTE")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Note Title (e.g. todo.md)", text: $newNoteTitle)
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
        // Rename Directory Popover
        .sheet(isPresented: $showingRenameDirectory) {
            VStack(spacing: 16) {
                Text("RENAME DIRECTORY")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Directory Name", text: $renameDirectoryName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                HStack {
                    Button("Cancel") {
                        showingRenameDirectory = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        if let directory = renameDirectoryTarget, !renameDirectoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.renameDirectory(directory, to: renameDirectoryName)
                            showingRenameDirectory = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 280)
        }
        // Rename Note Popover
        .sheet(isPresented: $showingRenameNote) {
            VStack(spacing: 16) {
                Text("RENAME NOTE")
                    .font(.system(.headline, design: .monospaced))
                
                TextField("Note Title", text: $renameNoteTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                HStack {
                    Button("Cancel") {
                        showingRenameNote = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        if let note = renameNoteTarget, !renameNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.renameNote(note, to: renameNoteTitle)
                            showingRenameNote = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 280)
        }
    }
}

struct DirectorySectionView: View {
    @Environment(AppStore.self) private var store
    var directory: Directory
    var onAddNote: () -> Void
    var onRenameDirectory: (Directory) -> Void
    var onRenameNote: (Note) -> Void
    var onDeleteDirectory: (Directory) -> Void
    var onDeleteNote: (Note) -> Void
    
    @State private var isDropTarget = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header Row
            HStack(spacing: 6) {
                Button(action: {
                    store.toggleDirectoryCollapse(directory)
                }) {
                    Text(directory.isCollapsed ? "▶" : "▼")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
                
                Text("📁 \(directory.name)/")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(isDropTarget
                        ? Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0))
                        : Color(nsColor: NSColor(red: 0.90, green: 0.70, blue: 0.31, alpha: 1.0)))
                
                Spacer()
                
                Button(action: onAddNote) {
                    Image(systemName: "plus")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Add note to this folder")
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(isDropTarget ? Color(nsColor: NSColor(red: 0.12, green: 0.18, blue: 0.14, alpha: 1.0)) : Color.clear)
            .cornerRadius(4)
            .contextMenu {
                Button("Rename Folder...") {
                    onRenameDirectory(directory)
                }
                Button("Delete Folder", role: .destructive) {
                    onDeleteDirectory(directory)
                }
            }
            .dropDestination(for: String.self) { items, _ in
                guard let uuidString = items.first,
                      let noteId = UUID(uuidString: uuidString),
                      let note = store.notes.first(where: { $0.id == noteId }),
                      note.directoryId != directory.id else { return false }
                store.moveNote(note, to: directory.id)
                return true
            } isTargeted: { targeted in
                isDropTarget = targeted
            }
            
            // Child Notes
            if !directory.isCollapsed {
                let sortedNotes = store.notesForDirectory(directory.id)
                
                if sortedNotes.isEmpty {
                    HStack(spacing: 0) {
                        Text("└── (empty)")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 12)
                } else {
                    ForEach(0..<sortedNotes.count, id: \.self) { index in
                        let note = sortedNotes[index]
                        let isLast = index == sortedNotes.count - 1
                        let connector = isLast ? "└── " : "├── "
                        
                        HStack(spacing: 0) {
                            Text(connector)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                store.openTab(note)
                            }) {
                                Text(note.title)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(store.activeTabId == note.id ? Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)) : .white)
                                    .padding(.horizontal, 4)
                                    .background(store.activeTabId == note.id ? Color(nsColor: NSColor(red: 0.16, green: 0.23, blue: 0.20, alpha: 1.0)) : Color.clear)
                                    .cornerRadius(3)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Rename Note...") {
                                    onRenameNote(note)
                                }
                                Button("Delete Note", role: .destructive) {
                                    onDeleteNote(note)
                                }
                            }
                            .draggable(note.id.uuidString)
                        }
                        .padding(.leading, 12)
                    }
                }
            }
        }
    }
}

struct SearchResultsView: View {
    @Environment(AppStore.self) private var store
    var onRenameNote: (Note) -> Void
    var onDeleteNote: (Note) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🔍 SEARCH RESULTS:")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            let results = store.filteredNotes
            
            if results.isEmpty {
                Text("No notes found.")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            } else {
                ForEach(results) { note in
                    Button(action: {
                        store.openTab(note)
                    }) {
                        HStack {
                            Text("📄 \(note.title)")
                                .font(.system(.body, design: .monospaced))
                            if let dir = store.directories.first(where: { $0.id == note.directoryId }) {
                                Spacer()
                                Text("[\(dir.name)]")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(store.activeTabId == note.id ? Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)) : .white)
                        .padding(6)
                        .background(store.activeTabId == note.id ? Color(nsColor: NSColor(red: 0.16, green: 0.23, blue: 0.20, alpha: 1.0)) : Color.clear)
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Rename Note...") {
                            onRenameNote(note)
                        }
                        Button("Delete Note", role: .destructive) {
                            onDeleteNote(note)
                        }
                    }
                }
            }
        }
    }
}
