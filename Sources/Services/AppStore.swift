import Foundation
import SwiftUI

@Observable
class AppStore {
    var directories: [Directory] = []
    var notes: [Note] = []
    var searchText: String = ""
    
    // MARK: - Tab System
    var openTabs: [Note] = []
    var activeTabId: UUID? = nil
    
    var activeNote: Note? {
        guard let id = activeTabId else { return nil }
        return openTabs.first(where: { $0.id == id })
    }
    
    private var saveTimer: Timer?
    
    init() {
        loadData()
    }
    
    func loadData() {
        self.directories = DatabaseManager.shared.fetchDirectories()
        self.notes = DatabaseManager.shared.fetchAllNotes()
    }
    
    // MARK: - Tab Operations
    
    func openTab(_ note: Note) {
        if !openTabs.contains(where: { $0.id == note.id }) {
            openTabs.append(note)
        }
        activeTabId = note.id
    }
    
    func closeTab(_ noteId: UUID) {
        guard let index = openTabs.firstIndex(where: { $0.id == noteId }) else { return }
        openTabs.remove(at: index)
        
        if activeTabId == noteId {
            if openTabs.isEmpty {
                activeTabId = nil
            } else {
                let newIndex = min(index, openTabs.count - 1)
                activeTabId = openTabs[newIndex].id
            }
        }
    }
    
    func closeActiveTab() {
        guard let id = activeTabId else { return }
        closeTab(id)
    }
    
    func switchToPreviousTab() {
        guard let id = activeTabId,
              let index = openTabs.firstIndex(where: { $0.id == id }),
              index > 0 else { return }
        activeTabId = openTabs[index - 1].id
    }
    
    func switchToNextTab() {
        guard let id = activeTabId,
              let index = openTabs.firstIndex(where: { $0.id == id }),
              index < openTabs.count - 1 else { return }
        activeTabId = openTabs[index + 1].id
    }
    
    // MARK: - Directory Operations
    
    func addDirectory(name: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanName.isEmpty else { return }
        
        let newDir = Directory(name: cleanName, sortOrder: directories.count)
        DatabaseManager.shared.insertDirectory(newDir)
        directories.append(newDir)
    }
    
    func toggleDirectoryCollapse(_ directory: Directory) {
        guard let index = directories.firstIndex(where: { $0.id == directory.id }) else { return }
        directories[index].isCollapsed.toggle()
        DatabaseManager.shared.updateDirectory(directories[index])
    }
    
    func deleteDirectory(_ directory: Directory) {
        // Close tabs for notes in this directory
        let dirNoteIds = notes.filter { $0.directoryId == directory.id }.map { $0.id }
        for noteId in dirNoteIds {
            closeTab(noteId)
        }
        
        notes.removeAll { $0.directoryId == directory.id }
        directories.removeAll { $0.id == directory.id }
        DatabaseManager.shared.deleteDirectory(id: directory.id)
    }
    
    func renameDirectory(_ directory: Directory, to newName: String) {
        let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanName.isEmpty else { return }
        guard let index = directories.firstIndex(where: { $0.id == directory.id }) else { return }
        directories[index].name = cleanName
        DatabaseManager.shared.updateDirectory(directories[index])
    }
    
    // MARK: - Note Operations
    
    func addNote(title: String, directoryId: UUID) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        
        let formattedTitle = cleanTitle.contains(".") ? cleanTitle : "\(cleanTitle).md"
        let newNote = Note(title: formattedTitle, content: "", directoryId: directoryId)
        
        DatabaseManager.shared.insertNote(newNote)
        notes.append(newNote)
        openTab(newNote)
    }
    
    func updateNoteContent(noteId: UUID, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }) else { return }
        notes[index].content = content
        notes[index].updatedAt = Date()
        
        // Sync the tab's content
        if let tabIndex = openTabs.firstIndex(where: { $0.id == noteId }) {
            openTabs[tabIndex].content = content
            openTabs[tabIndex].updatedAt = notes[index].updatedAt
        }
        
        // Debounce database writing (500ms)
        saveTimer?.invalidate()
        let noteToSave = notes[index]
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            DatabaseManager.shared.updateNote(noteToSave)
        }
    }
    
    func renameNote(_ note: Note, to newTitle: String) {
        let cleanTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        let formattedTitle = cleanTitle.contains(".") ? cleanTitle : "\(cleanTitle).md"
        notes[index].title = formattedTitle
        notes[index].updatedAt = Date()
        DatabaseManager.shared.updateNote(notes[index])
        
        // Sync tab title
        if let tabIndex = openTabs.firstIndex(where: { $0.id == note.id }) {
            openTabs[tabIndex].title = formattedTitle
            openTabs[tabIndex].updatedAt = notes[index].updatedAt
        }
    }
    
    func deleteNote(_ note: Note) {
        closeTab(note.id)
        notes.removeAll { $0.id == note.id }
        DatabaseManager.shared.deleteNote(id: note.id)
    }
    
    func moveNote(_ note: Note, to directoryId: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].directoryId = directoryId
        notes[index].updatedAt = Date()
        DatabaseManager.shared.updateNote(notes[index])
        
        // Sync tab
        if let tabIndex = openTabs.firstIndex(where: { $0.id == note.id }) {
            openTabs[tabIndex].directoryId = directoryId
            openTabs[tabIndex].updatedAt = notes[index].updatedAt
        }
    }
    
    // MARK: - Sidebar Tree Helpers
    
    func notesForDirectory(_ directoryId: UUID) -> [Note] {
        notes.filter { $0.directoryId == directoryId }
             .sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { note in
                note.title.localizedStandardContains(searchText) ||
                note.content.localizedStandardContains(searchText)
            }
        }
    }
}
