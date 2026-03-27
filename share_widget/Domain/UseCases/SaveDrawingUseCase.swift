import Foundation

struct SaveDrawingUseCase {
    let repository: NoteRepository

    func execute(noteID: UUID, drawingData: Data) async throws -> Note {
        try await repository.saveDrawing(noteID: noteID, drawingData: drawingData)
    }
}
