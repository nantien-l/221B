import Foundation

struct CaseTimeline {
    let entries: [CaseTimelineEntry]
    let source: URL
}

struct CaseTimelineRepository {
    private struct Record: Decodable {
        struct Entry: Decodable {
            let storyId: String
            let year: Int
            let order: Int
        }
        let source: URL
        let entries: [Entry]
    }

    func load(stories: [Story], bundle: Bundle = .main) throws -> CaseTimeline {
        guard let url = bundle.url(forResource: "case-chronology", withExtension: "json", subdirectory: "Data")
                ?? bundle.url(forResource: "case-chronology", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "Case chronology is unavailable."])
        }
        let record = try JSONDecoder().decode(Record.self, from: Data(contentsOf: url))
        let byID = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
        let sorted = record.entries.sorted { $0.order < $1.order }
        guard sorted.count == stories.count,
              Set(sorted.map(\.storyId)).count == stories.count,
              sorted.map(\.order) == Array(1...stories.count),
              sorted.allSatisfy({ byID[$0.storyId] != nil }),
              zip(sorted, sorted.dropFirst()).allSatisfy({ $0.year <= $1.year }) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Case chronology does not match the library."])
        }
        return CaseTimeline(entries: sorted.compactMap { item in
            byID[item.storyId].map { CaseTimelineEntry(story: $0, year: item.year, order: item.order) }
        }, source: record.source)
    }
}
