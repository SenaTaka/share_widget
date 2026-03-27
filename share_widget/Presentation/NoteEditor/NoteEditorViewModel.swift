import Foundation
import Combine
import PencilKit

@MainActor
final class NoteEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var syncState: SyncState = .idle
    @Published var drawing: PKDrawing = PKDrawing()
    @Published var selectedEntryType: NoteEntryType = .handwriting
    @Published var messageText: String = ""
    @Published var authorUserID: String = ""
    @Published var photoReference: String?

    private let noteID: UUID
    private let repository: NoteRepository
    private let saveDrawingUseCase: SaveDrawingUseCase
    private let refreshWidgetUseCase: RefreshWidgetUseCase

    private var saveTask: Task<Void, Never>?

    init(noteID: UUID, repository: NoteRepository, widgetBridge: WidgetBridge) {
        self.noteID = noteID
        self.repository = repository
        self.saveDrawingUseCase = SaveDrawingUseCase(repository: repository)
        self.refreshWidgetUseCase = RefreshWidgetUseCase(repository: repository, widgetBridge: widgetBridge)
    }

    func load() {
        Task {
            do {
                guard let note = try await repository.fetchNote(noteID: noteID) else {
                    syncState = .error("Note not found")
                    return
                }
                title = note.title
                selectedEntryType = note.entryType
                messageText = note.messageText ?? ""
                authorUserID = note.authorUserID ?? ""
                photoReference = note.photoReference
                if let restored = try? PKDrawing(data: note.drawingData) {
                    drawing = restored
                }
                syncState = .synced(note.updatedAt)
            } catch {
                syncState = .error(error.localizedDescription)
            }
        }
    }

    func updateTitle() {
        Task {
            do {
                _ = try await repository.updateTitle(noteID: noteID, title: title)
                await refreshWidgetUseCase.execute()
            } catch {
                syncState = .error(error.localizedDescription)
            }
        }
    }

    func drawingDidChange(_ updated: PKDrawing) {
        Task { @MainActor in
            drawing = updated
            scheduleSave()
        }
    }

    func setSelectedPhotoData(_ data: Data?) {
        guard let data else {
            photoReference = nil
            return
        }
        photoReference = "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    func savePhotoMessage() {
        Task {
            await persistPhotoMessage()
        }
    }

    func forceSaveBeforeExit() {
        saveTask?.cancel()
        saveTask = Task {
            if selectedEntryType == .handwriting {
                await saveDrawing()
            } else {
                await persistPhotoMessage()
            }
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await saveDrawing()
        }
    }

    private func saveDrawing() async {
        syncState = .saving
        do {
            let data = drawing.dataRepresentation()
            let note = try await saveDrawingUseCase.execute(noteID: noteID, drawingData: data)
            syncState = .synced(note.updatedAt)
            await refreshWidgetUseCase.execute()
        } catch {
            syncState = .error(error.localizedDescription)
        }
    }

    private func persistPhotoMessage() async {
        syncState = .saving
        do {
            guard let photoReference, !photoReference.isEmpty else {
                syncState = .error("Please select a photo")
                return
            }

            let note = try await repository.updatePhotoMessageEntry(
                noteID: noteID,
                title: title,
                photoReference: photoReference,
                messageText: messageText,
                authorUserID: authorUserID
            )
            syncState = .synced(note.updatedAt)
            await refreshWidgetUseCase.execute()
        } catch {
            syncState = .error(error.localizedDescription)
        }
    }
}
