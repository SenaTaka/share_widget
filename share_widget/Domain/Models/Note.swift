import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var drawingData: Data
    var isPinnedToWidget: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        drawingData: Data = Data(),
        isPinnedToWidget: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.drawingData = drawingData
        self.isPinnedToWidget = isPinnedToWidget
        self.updatedAt = updatedAt
    }
}
