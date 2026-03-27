import Foundation
import Combine

@MainActor
final class ConflictResolutionViewModel: ObservableObject {
    @Published private(set) var conflict: ConflictResolution
    @Published var selectedAction: ConflictResolutionAction?

    init(conflict: ConflictResolution) {
        self.conflict = conflict
    }

    func selectAction(_ action: ConflictResolutionAction) {
        selectedAction = action
    }
}
