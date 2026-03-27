import Foundation

protocol NoteRepository {
    func fetchNotes() async throws -> [Note]
    func createNote(title: String) async throws -> Note
    func updateTitle(noteID: UUID, title: String) async throws -> Note
    func saveDrawing(noteID: UUID, drawingData: Data) async throws -> Note
    func delete(noteID: UUID) async throws
    func fetchNote(noteID: UUID) async throws -> Note?
}
