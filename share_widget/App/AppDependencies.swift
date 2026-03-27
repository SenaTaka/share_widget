import Foundation
import Combine

@MainActor
final class AppDependencies: ObservableObject {
    let workspaceRepository: WorkspaceRepository
    let noteRepository: NoteRepository
    let widgetBridge: WidgetBridge

    init(
        workspaceRepository: WorkspaceRepository = InMemoryWorkspaceRepository(),
        noteRepository: NoteRepository = InMemoryNoteRepository(),
        widgetBridge: WidgetBridge = AppGroupWidgetBridge()
    ) {
        self.workspaceRepository = workspaceRepository
        self.noteRepository = noteRepository
        self.widgetBridge = widgetBridge
    }
}
