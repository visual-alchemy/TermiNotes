import Foundation

struct Directory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var sortOrder: Int
    var isCollapsed: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, sortOrder: Int = 0, isCollapsed: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.isCollapsed = isCollapsed
        self.createdAt = createdAt
    }
}
