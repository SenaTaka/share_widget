import SwiftUI

struct RootView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        WorkspaceListScreen(
            viewModel: WorkspaceListViewModel(
                workspaceRepository: dependencies.workspaceRepository
            )
        )
    }
}
