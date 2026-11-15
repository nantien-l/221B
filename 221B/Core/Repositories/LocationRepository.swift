import Foundation

struct LocationRepository {
    struct LocationData {
        let locations: [Location]
        let storyLocations: [StoryLocation]
    }

    private struct Index: Decodable {
        struct Record: Decodable {
            let id: String
            let name: String
            let description: String
            let storyIds: [String]
        }
        let locations: [Record]
    }

    func load(stories: [Story], bundle: Bundle = .main) throws -> LocationData {
        guard let url = bundle.url(forResource: "locations", withExtension: "json", subdirectory: "Data")
                ?? bundle.url(forResource: "locations", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "Location index is unavailable."])
        }
        let records = try JSONDecoder().decode(Index.self, from: Data(contentsOf: url)).locations
        let storyByID = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
        guard records.count == 26, Set(records.map(\.id)).count == records.count,
              records.allSatisfy({ !$0.name.isEmpty && !$0.storyIds.isEmpty && Set($0.storyIds).count == $0.storyIds.count && $0.storyIds.allSatisfy { storyByID[$0] != nil } }) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Location index contains invalid records."])
        }
        var locations: [Location] = []
        var links: [StoryLocation] = []
        for record in records {
            let location = Location(id: record.id, name: record.name, description: record.description)
            locations.append(location)
            for id in record.storyIds {
                if let story = storyByID[id] {
                    links.append(StoryLocation(story: story, location: location, significance: nil))
                }
            }
        }
        return LocationData(locations: locations, storyLocations: links)
    }
}
