import Foundation

public struct WidgetNoteSnapshot: Codable, Equatable {
    public let noteID: UUID
    public let title: String
    public let body: String
    public let updatedAt: Date

    public init(noteID: UUID, title: String, body: String, updatedAt: Date) {
        self.noteID = noteID
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
    }

    public static let dummy = WidgetNoteSnapshot(
        noteID: UUID(uuidString: "11111111-2222-3333-4444-555555555555") ?? UUID(),
        title: "Widget Preview",
        body: "最初は固定のダミーデータを表示しています。",
        updatedAt: Date()
    )
}
