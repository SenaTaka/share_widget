import Foundation
import Combine
import PencilKit

@MainActor
final class NoteEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var syncState: SyncState = .idle
    @Published var drawing: PKDrawing = PKDrawing()

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
        drawing = updated
        scheduleSave()
    }

    func forceSaveBeforeExit() {
        saveTask?.cancel()
        saveTask = Task { await saveDrawing() }
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
}
