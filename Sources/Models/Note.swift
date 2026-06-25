import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var directoryId: UUID
    
    init(id: UUID = UUID(), title: String, content: String = "", createdAt: Date = Date(), updatedAt: Date = Date(), directoryId: UUID) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.directoryId = directoryId
    }
}
