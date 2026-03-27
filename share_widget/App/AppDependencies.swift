import Foundation

@MainActor
final class AppDependencies: ObservableObject {
    let noteRepository: NoteRepository
    let widgetBridge: WidgetBridge

    init(
        noteRepository: NoteRepository = InMemoryNoteRepository(),
        widgetBridge: WidgetBridge = AppGroupWidgetBridge()
    ) {
        self.noteRepository = noteRepository
        self.widgetBridge = widgetBridge
    }
}
