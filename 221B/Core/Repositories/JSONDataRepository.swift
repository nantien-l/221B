import SwiftUI
import Observation
import Foundation

class JSONDataRepository {
    static let shared = JSONDataRepository()

    private init() {}

    func loadSampleData() -> (collections: [Collection], stories: [Story], characters: [Character], locations: [Location], appearances: [Appearance], storyLocations: [StoryLocation], chronologyEntries: [ChronologyEntry]) {
        // Create collections with sample data
        let collection1 = Collection(title: "A Study in Scarlet", year: 1887, stories: [])
        let collection2 = Collection(title: "The Hound of the Baskervilles", year: 1902, stories: [])
        let collection3 = Collection(title: "The Sign of the Four", year: 1888, stories: [])

        // Create stories
        let story1 = Story(title: "A Study in Scarlet", collection: collection1, publicationYear: 1887)
        let story2 = Story(title: "The Sign of the Four", collection: collection3, publicationYear: 1888)
        let story3 = Story(title: "The Hound of the Baskervilles", collection: collection2, publicationYear: 1902)

        // Update collections with stories
        collection1.stories = [story1]
        collection2.stories = [story3]
        collection3.stories = [story2]

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
        let appearance6 = Appearance(character: criminal, story: story3, role: .antagonist, isMention: false)
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

        // Create chronology entries
        let chronoEntry1 = ChronologyEntry(
            story: story1,
            proposedDate: Date(timeIntervalSince1970: 0),
            source: "Original Publication",
            notes: "First published in 1887 as a serial in Beeton's Christmas Annual."
        )
        let chronoEntry2 = ChronologyEntry(
            story: story2,
            proposedDate: Date(timeIntervalSince1970: 86400),
            source: "Original Publication",
            notes: "First published in 1888 as a serial in The Strand magazine."
        )
        let chronoEntry3 = ChronologyEntry(
            story: story3,
            proposedDate: Date(timeIntervalSince1970: 365*14*2),
            source: "Original Publication",
            notes: "First published in 1902 as a serial in The Strand magazine."
        )

        return (
            collections: [collection1, collection2, collection3],
            stories: [story1, story2, story3],
            characters: [detective, client1, criminal, friend, family],
            locations: [london, bakerStreet, strand, countryHouse],
            appearances: [appearance1, appearance2, appearance3, appearance4, appearance5, appearance6, appearance7, appearance8],
            storyLocations: [storyLocation1, storyLocation2, storyLocation3, storyLocation4, storyLocation5, storyLocation6, storyLocation7],
            chronologyEntries: [chronoEntry1, chronoEntry2, chronoEntry3]
        )
    }
}
