import Foundation
import SQLite3

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    init() {
        openDatabase()
        createTables()
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    private func openDatabase() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Could not access Application Support directory")
        }
        
        let appDirURL = appSupportURL.appendingPathComponent("TermiNotes", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appDirURL.path) {
            try? fileManager.createDirectory(at: appDirURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let dbURL = appDirURL.appendingPathComponent("terminotes.sqlite")
        
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Database opened successfully at \(dbURL.path)")
        }
    }
    
    private func createTables() {
        let createDirectoriesTable = """
        CREATE TABLE IF NOT EXISTS directories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            sortOrder INTEGER NOT NULL DEFAULT 0,
            isCollapsed INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
        );
        """
        
        let createNotesTable = """
        CREATE TABLE IF NOT EXISTS notes (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            directoryId TEXT NOT NULL,
            FOREIGN KEY (directoryId) REFERENCES directories (id) ON DELETE CASCADE
        );
        """
        
        // Enable foreign key support
        execute(sql: "PRAGMA foreign_keys = ON;")
        execute(sql: createDirectoriesTable)
        execute(sql: createNotesTable)
    }
    
    private func execute(sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error executing statement: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing statement: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Directory CRUD
    
    func fetchDirectories() -> [Directory] {
        let query = "SELECT id, name, sortOrder, isCollapsed, createdAt FROM directories ORDER BY sortOrder ASC;"
        var statement: OpaquePointer?
        var list: [Directory] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let idStr = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let sortOrder = Int(sqlite3_column_int(statement, 2))
                let isCollapsed = sqlite3_column_int(statement, 3) != 0
                let createdAtStr = String(cString: sqlite3_column_text(statement, 4))
                
                if let id = UUID(uuidString: idStr), let createdAt = dateFormatter.date(from: createdAtStr) {
                    list.append(Directory(id: id, name: name, sortOrder: sortOrder, isCollapsed: isCollapsed, createdAt: createdAt))
                }
            }
        }
        sqlite3_finalize(statement)
        return list
    }
    
    func insertDirectory(_ directory: Directory) {
        let sql = "INSERT INTO directories (id, name, sortOrder, isCollapsed, createdAt) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, directory.id.uuidString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, directory.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 3, Int32(directory.sortOrder))
            sqlite3_bind_int(statement, 4, directory.isCollapsed ? 1 : 0)
            sqlite3_bind_text(statement, 5, dateFormatter.string(from: directory.createdAt), -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error inserting directory: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func updateDirectory(_ directory: Directory) {
        let sql = "UPDATE directories SET name = ?, sortOrder = ?, isCollapsed = ? WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, directory.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, Int32(directory.sortOrder))
            sqlite3_bind_int(statement, 3, directory.isCollapsed ? 1 : 0)
            sqlite3_bind_text(statement, 4, directory.id.uuidString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error updating directory: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func deleteDirectory(id: UUID) {
        execute(sql: "PRAGMA foreign_keys = ON;")
        let sql = "DELETE FROM directories WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error deleting directory: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Note CRUD
    
    func fetchAllNotes() -> [Note] {
        let query = "SELECT id, title, content, createdAt, updatedAt, directoryId FROM notes;"
        var statement: OpaquePointer?
        var list: [Note] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let idStr = String(cString: sqlite3_column_text(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let content = String(cString: sqlite3_column_text(statement, 2))
                let createdAtStr = String(cString: sqlite3_column_text(statement, 3))
                let updatedAtStr = String(cString: sqlite3_column_text(statement, 4))
                let directoryIdStr = String(cString: sqlite3_column_text(statement, 5))
                
                if let id = UUID(uuidString: idStr),
                   let createdAt = dateFormatter.date(from: createdAtStr),
                   let updatedAt = dateFormatter.date(from: updatedAtStr),
                   let directoryId = UUID(uuidString: directoryIdStr) {
                    list.append(Note(id: id, title: title, content: content, createdAt: createdAt, updatedAt: updatedAt, directoryId: directoryId))
                }
            }
        }
        sqlite3_finalize(statement)
        return list
    }
    
    func insertNote(_ note: Note) {
        let sql = "INSERT INTO notes (id, title, content, createdAt, updatedAt, directoryId) VALUES (?, ?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, note.id.uuidString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, note.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, note.content, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, dateFormatter.string(from: note.createdAt), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, dateFormatter.string(from: note.updatedAt), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, note.directoryId.uuidString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error inserting note: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func updateNote(_ note: Note) {
        let sql = "UPDATE notes SET title = ?, content = ?, updatedAt = ?, directoryId = ? WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, note.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, note.content, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, dateFormatter.string(from: note.updatedAt), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, note.directoryId.uuidString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, note.id.uuidString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error updating note: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func deleteNote(id: UUID) {
        let sql = "DELETE FROM notes WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            if sqlite3_step(statement) != SQLITE_DONE {
                let err = String(cString: sqlite3_errmsg(db))
                print("Error deleting note: \(err)")
            }
        }
        sqlite3_finalize(statement)
    }
}
