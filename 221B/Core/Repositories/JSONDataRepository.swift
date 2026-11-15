import SwiftUI
import Observation
import Foundation

class JSONDataRepository {
    static let shared = JSONDataRepository()

    private init() {}

    struct Bibliography {
        let collections: [Collection]
        let novels: [Story]
        let stories: [Story]
    }

    private struct WorkRecord: Decodable {
        let id: String
        let title: String
        let type: String
        let firstUKPublicationYear: Int
        let publicationYear: Int?
        let collectionId: String?
        let position: Int?
        let bookOrder: Int?
    }

    private struct CollectionRecord: Decodable {
        let id: String
        let title: String
        let publicationYear: Int
        let bookOrder: Int
        let storyCount: Int
    }

    func loadBibliography(bundle: Bundle = .main) throws -> Bibliography {
        func decode<T: Decodable>(_ name: String, as: T.Type) throws -> T {
            guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Data")
                    ?? bundle.url(forResource: name, withExtension: "json") else {
                throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "Missing bibliography resource: \(name).json"])
            }
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        }
        let collectionRecords = try decode("collections", as: [CollectionRecord].self)
        let novelRecords = try decode("novels", as: [WorkRecord].self)
        let storyRecords = try decode("stories", as: [WorkRecord].self)
        let allRecords = novelRecords + storyRecords
        guard collectionRecords.count == 5, novelRecords.count == 4, storyRecords.count == 56,
              Set(allRecords.map(\.id)).count == 60,
              Set(collectionRecords.map(\.id)).count == 5,
              Set(allRecords.map { $0.title.lowercased() }).count == 60,
              collectionRecords.allSatisfy({ $0.storyCount > 0 }),
              Set(collectionRecords.map(\.bookOrder) + novelRecords.compactMap(\.bookOrder)) == Set(1...9),
              novelRecords.allSatisfy({ $0.type == "novel" && $0.collectionId == nil && $0.bookOrder != nil }),
              storyRecords.allSatisfy({ $0.type == "shortStory" && $0.collectionId != nil && $0.position != nil }) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Invalid bibliography records."])
        }
        let collections = collectionRecords.map { Collection(id: $0.id, title: $0.title, year: $0.publicationYear, bookOrder: $0.bookOrder, stories: []) }
        let byID = Dictionary(uniqueKeysWithValues: collections.map { ($0.id, $0) })
        var stories: [Story] = []
        for record in storyRecords {
            guard let collectionID = record.collectionId, let collection = byID[collectionID], let position = record.position else {
                throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Invalid collection reference."])
            }
            stories.append(Story(id: record.id, title: record.title, collection: collection, publicationYear: record.firstUKPublicationYear, position: position))
        }
        for (record, collection) in zip(collectionRecords, collections) {
            collection.stories = stories.filter { $0.collection?.id == collection.id }.sorted { $0.position < $1.position }
            guard collection.stories.count == record.storyCount,
                  collection.stories.map(\.position) == Array(1...record.storyCount) else {
                throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Invalid collection order or count."])
            }
        }
        let novels = novelRecords.map { Story(id: $0.id, title: $0.title, collection: nil, publicationYear: $0.publicationYear ?? $0.firstUKPublicationYear, bookOrder: $0.bookOrder) }
        return Bibliography(collections: collections, novels: novels, stories: novels + collections.sorted { $0.bookOrder < $1.bookOrder }.flatMap(\.stories))
    }

    func loadLegacyEntities(stories: [Story]) throws -> (characters: [Character], locations: [Location], appearances: [Appearance], storyLocations: [StoryLocation]) {
        // Preserve the existing relationships, now pointing to decoded canonical works.
        guard let story1 = stories.first(where: { $0.id == "a-study-in-scarlet" }),
              let story2 = stories.first(where: { $0.id == "the-sign-of-four" }),
              let story3 = stories.first(where: { $0.id == "the-hound-of-the-baskervilles" }) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Required canonical works are missing."])
        }

        // Create characters
        let detective = Character(
            name: "Sherlock Holmes",
            aliases: ["The Great Detective", "Consulting Detective"],
            category: .detective,
            biography: "A brilliant consulting detective known for his sharp intellect and deductive reasoning. Famous for his deerstalker hat and pipe. Works from his residence at 221B Baker Street. Associated with Dr. Watson. Arch-enemy is Professor Moriarty."
        )

        let client1 = Character(
            name: "Dr. John Watson",
            aliases: ["Watson", "Dr. Watson"],
            category: .client,
            biography: "A medical doctor and Sherlock Holmes' loyal friend and chronicler. Serves as Holmes' companion and narrator. Former military surgeon. Provides emotional grounding for Holmes."
        )

        let criminal = Character(
            name: "Professor James Moriarty",
            aliases: ["Moriarty", "The Napoleon of Crime"],
            category: .criminal,
            biography: "A criminal mastermind who is Sherlock Holmes' greatest enemy. Runs a criminal empire from his base at 7 The Strand. Known as the 'Napoleon of Crime'."
        )

        let friend = Character(
            name: "Inspector Lestrade",
            aliases: ["Lestrade"],
            category: .friend,
            biography: "A police inspector at Scotland Yard who frequently works with Sherlock Holmes. Though often frustrated by Holmes' methods, he respects his abilities."
        )

        let family = Character(
            name: "Mrs. Hudson",
            aliases: [],
            category: .family,
            biography: "The landlady of 221B Baker Street. Manages Holmes' residence and provides domestic support. Known for her hospitality and practical nature."
        )

        // Create locations
        let london = Location(name: "London", description: "The bustling capital city of England, center of Victorian society and crime.")
        let bakerStreet = Location(name: "221B Baker Street", description: "Sherlock Holmes' famous residence, a flat above a haberdasher's shop.")
        let strand = Location(name: "The Strand", description: "A major road in London, home to many legal establishments and Moriarty's base of operations.")
        let countryHouse = Location(name: "Hartley House", description: "A country house used by Holmes and Watson for investigations, particularly in rural settings.")

        // Create appearances
        let appearance1 = Appearance(character: detective, story: story1, role: .protagonist, isMention: false)
        let appearance2 = Appearance(character: client1, story: story1, role: .protagonist, isMention: false)
        let appearance3 = Appearance(character: detective, story: story2, role: .protagonist, isMention: false)
        let appearance4 = Appearance(character: client1, story: story2, role: .protagonist, isMention: false)
        let appearance5 = Appearance(character: detective, story: story3, role: .protagonist, isMention: false)
        let appearance7 = Appearance(character: friend, story: story3, role: .supporting, isMention: false)
        let appearance8 = Appearance(character: family, story: story1, role: .supporting, isMention: false)

        // Create story locations
        let storyLocation1 = StoryLocation(story: story1, location: london, significance: .central)
        let storyLocation2 = StoryLocation(story: story1, location: bakerStreet, significance: .central)
        let storyLocation3 = StoryLocation(story: story2, location: london, significance: .important)
        let storyLocation4 = StoryLocation(story: story2, location: strand, significance: .central)
        let storyLocation5 = StoryLocation(story: story3, location: london, significance: .central)
        let storyLocation6 = StoryLocation(story: story3, location: bakerStreet, significance: .central)
        let storyLocation7 = StoryLocation(story: story3, location: countryHouse, significance: .important)

        return (
            characters: [detective, client1, criminal, friend, family],
            locations: [london, bakerStreet, strand, countryHouse],
            appearances: [appearance1, appearance2, appearance3, appearance4, appearance5, appearance7, appearance8],
            storyLocations: [storyLocation1, storyLocation2, storyLocation3, storyLocation4, storyLocation5, storyLocation6, storyLocation7]
        )
    }
}
