import SwiftUI

struct ContentView: View {
    private let viewModelFactory: () -> WorkspaceListViewModel

    init(viewModelFactory: @escaping () -> WorkspaceListViewModel) {
        self.viewModelFactory = viewModelFactory
    }

    var body: some View {
        WorkspaceListScreen(viewModel: viewModelFactory())
    }
}

#Preview {
    ContentView(viewModelFactory: {
        WorkspaceListViewModel(workspaceRepository: InMemoryWorkspaceRepository())
    })
}
