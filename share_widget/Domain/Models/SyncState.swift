import Foundation

enum SyncState: Equatable, Hashable, Sendable {
    case idle
    case saving
    case syncing
    case synced(Date)
    case conflict
    case error(String)

    var displayText: String {
        switch self {
        case .idle:
            return "Idle"
        case .saving:
            return "Saving..."
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .conflict:
            return "Conflict"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}
