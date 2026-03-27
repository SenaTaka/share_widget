import Foundation

struct RefreshWidgetUseCase {
    private let repository: NoteRepository
    private let widgetBridge: WidgetBridge

    init(repository: NoteRepository, widgetBridge: WidgetBridge) {
        self.repository = repository
        self.widgetBridge = widgetBridge
    }

    func execute() async {
        let pinnedNote = try? await repository.fetchPinnedNote()
        await widgetBridge.syncPinnedNote(pinnedNote ?? nil)
    }
}
