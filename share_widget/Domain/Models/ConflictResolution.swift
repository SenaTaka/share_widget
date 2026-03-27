import Foundation

struct ConflictResolution: Identifiable, Equatable, Sendable {
    let id: UUID
    let noteID: UUID
    let noteTitle: String
    let localVersion: ConflictVersion
    let remoteVersion: ConflictVersion
    let detectedAt: Date

    init(
        id: UUID = UUID(),
        noteID: UUID,
        noteTitle: String,
        localVersion: ConflictVersion,
        remoteVersion: ConflictVersion,
        detectedAt: Date = Date()
    ) {
        self.id = id
        self.noteID = noteID
        self.noteTitle = noteTitle
        self.localVersion = localVersion
        self.remoteVersion = remoteVersion
        self.detectedAt = detectedAt
    }
}

struct ConflictVersion: Equatable, Sendable {
    let revision: Int64
    let updatedAt: Date
    let updatedByUserID: String
    let updatedByName: String
    let drawingData: Data

    init(
        revision: Int64,
        updatedAt: Date,
        updatedByUserID: String,
        updatedByName: String,
        drawingData: Data
    ) {
        self.revision = revision
        self.updatedAt = updatedAt
        self.updatedByUserID = updatedByUserID
        self.updatedByName = updatedByName
        self.drawingData = drawingData
    }
}

enum ConflictResolutionAction {
    case keepLocal
    case keepRemote
    case cancel
}
