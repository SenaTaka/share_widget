import SwiftUI

struct RootView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        WorkspaceListScreen(
            viewModel: WorkspaceListViewModel(
                workspaceRepository: dependencies.workspaceRepository
            ),
            noteRepository: dependencies.noteRepository,
            widgetBridge: dependencies.widgetBridge
        )
    }
}
