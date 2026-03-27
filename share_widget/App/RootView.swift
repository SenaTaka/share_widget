import SwiftUI

struct RootView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            WorkspaceListView(viewModel: WorkspaceListViewModel(repository: dependencies.noteRepository))
        }
    }
}
