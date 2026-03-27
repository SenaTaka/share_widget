import SwiftUI

struct Note: Identifiable, Equatable {
    let id: UUID
    let title: String
    let body: String
}

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
    ContentView(routedNoteID: .constant(nil))
}
