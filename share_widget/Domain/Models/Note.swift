import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var drawingData: Data
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, drawingData: Data = Data(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.drawingData = drawingData
        self.updatedAt = updatedAt
    }
}
