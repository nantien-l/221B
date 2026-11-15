import Foundation

/// Persists a reader's own library state separately from the bundled canon data.
struct UserLibraryStore {
    private static let storageKey = "221b.userLibrary.v1"

    struct Snapshot: Codable {
        var favoriteStoryIDs: Set<String> = []
        var favoriteCharacterIDs: Set<String> = []
        var favoriteLocationIDs: Set<String> = []
        var bookmarkedStoryIDs: Set<String> = []
        var storyProgress: [String: Double] = [:]
    }

    func load() -> Snapshot {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return Snapshot()
        }
        return snapshot
    }

    func save(_ snapshot: Snapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
