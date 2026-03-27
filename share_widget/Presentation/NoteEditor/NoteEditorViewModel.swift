import Foundation
import PencilKit

@MainActor
final class NoteEditorViewModel: ObservableObject {
    @Published var drawing: PKDrawing
    @Published private(set) var syncState: SyncState = .upToDate

    private let noteID: String
    private let repository: NoteDrawingRepository
    private let debounceNanoseconds: UInt64

    private var debounceTask: Task<Void, Never>?
    private var pendingData: Data?

    init(
        noteID: String,
        repository: NoteDrawingRepository = UserDefaultsNoteDrawingRepository(),
        debounceSeconds: TimeInterval = 1.8
    ) {
        self.noteID = noteID
        self.repository = repository
        self.debounceNanoseconds = UInt64(debounceSeconds * 1_000_000_000)

        if let data = repository.loadDrawingData(noteID: noteID),
           let loadedDrawing = try? PKDrawing(data: data) {
            drawing = loadedDrawing
        } else {
            drawing = PKDrawing()
        }
    }

    func drawingDidChange(_ updatedDrawing: PKDrawing) {
        drawing = updatedDrawing
        pendingData = updatedDrawing.dataRepresentation()
        scheduleDebouncedSave()
    }

    func forceSave() {
        debounceTask?.cancel()
        debounceTask = nil
        persistPendingData()
    }

    private func scheduleDebouncedSave() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            guard !Task.isCancelled else { return }
            self.persistPendingData()
        }
    }

    private func persistPendingData() {
        guard let data = pendingData else { return }

        syncState = .saving

        do {
            try repository.saveDrawingData(data, noteID: noteID)
            pendingData = nil
            syncState = .upToDate
        } catch {
            syncState = .error(error.localizedDescription)
        }
    }
}
