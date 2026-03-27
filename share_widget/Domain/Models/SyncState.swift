import Foundation

enum SyncState: Equatable {
    case idle
    case saving
    case synced(Date)
    case error(String)
}
