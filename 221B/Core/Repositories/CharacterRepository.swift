import Foundation

struct CharacterRepository {
    struct CharacterData {
        let characters: [Character]
        let appearances: [Appearance]
    }

    private struct Index: Decodable {
        struct Record: Decodable {
            let id: String
            let name: String
            let aliases: [String]
            let category: String
            let biography: String
            let storyIds: [String]
        }
        let characters: [Record]
    }

    func load(stories: [Story], bundle: Bundle = .main) throws -> CharacterData {
        guard let url = bundle.url(forResource: "characters", withExtension: "json", subdirectory: "Data")
                ?? bundle.url(forResource: "characters", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "Character index is unavailable."])
        }
        let records = try JSONDecoder().decode(Index.self, from: Data(contentsOf: url)).characters
        let storyByID = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
        guard records.count == 85, Set(records.map(\.id)).count == records.count,
              records.allSatisfy({ !$0.name.isEmpty && !$0.storyIds.isEmpty && Set($0.storyIds).count == $0.storyIds.count && $0.storyIds.allSatisfy { storyByID[$0] != nil } }) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Character index contains invalid records."])
        }
        var characters: [Character] = []
        var appearances: [Appearance] = []
        for record in records {
            guard let category = CharacterCategory(rawValue: record.category) else {
                throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unknown character category."])
            }
            let character = Character(id: record.id, name: record.name, aliases: record.aliases, category: category, biography: record.biography)
            characters.append(character)
            for id in record.storyIds {
                if let story = storyByID[id] {
                    appearances.append(Appearance(character: character, story: story, role: nil, isMention: nil))
                }
            }
        }
        return CharacterData(characters: characters, appearances: appearances)
    }
}
