import Foundation

enum SyncState: Equatable {
    case upToDate
    case saving
    case error(String)
}
