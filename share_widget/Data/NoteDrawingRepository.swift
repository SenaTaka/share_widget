import Foundation

protocol NoteDrawingRepository {
    func loadDrawingData(noteID: String) -> Data?
    func saveDrawingData(_ data: Data, noteID: String) throws
}

struct UserDefaultsNoteDrawingRepository: NoteDrawingRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadDrawingData(noteID: String) -> Data? {
        userDefaults.data(forKey: storageKey(noteID: noteID))
    }

    func saveDrawingData(_ data: Data, noteID: String) throws {
        userDefaults.set(data, forKey: storageKey(noteID: noteID))
    }

    private func storageKey(noteID: String) -> String {
        "note.drawing.\(noteID)"
    }
}
