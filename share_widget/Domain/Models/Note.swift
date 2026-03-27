import Foundation

enum NoteEntryType: String, Codable, Equatable {
    case handwriting
    case photoMessage
}

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var entryType: NoteEntryType
    var drawingData: Data
    var photoReference: String?
    var messageText: String?
    var authorUserID: String?
    var isPinnedToWidget: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        entryType: NoteEntryType = .handwriting,
        drawingData: Data = Data(),
        photoReference: String? = nil,
        messageText: String? = nil,
        authorUserID: String? = nil,
        isPinnedToWidget: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.entryType = entryType
        self.drawingData = drawingData
        self.photoReference = photoReference
        self.messageText = messageText
        self.authorUserID = authorUserID
        self.isPinnedToWidget = isPinnedToWidget
        self.updatedAt = updatedAt
    }
}
