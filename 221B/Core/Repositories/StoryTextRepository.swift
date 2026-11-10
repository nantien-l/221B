import Foundation

/// Loads the bundled text only when a reader opens a work.
final class StoryTextRepository {
    struct Source: Decodable {
        let id: String
        let source: URL
    }

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadText(for storyID: String) throws -> String {
        guard !storyID.isEmpty,
              storyID.allSatisfy({ $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "-") }),
              let url = bundle.url(forResource: storyID, withExtension: "txt", subdirectory: "Texts")
                ?? bundle.url(forResource: storyID, withExtension: "txt") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "The text for this work is unavailable."])
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    func source(for storyID: String) -> URL? {
        guard let url = bundle.url(forResource: "text-sources", withExtension: "json", subdirectory: "Data")
                ?? bundle.url(forResource: "text-sources", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let sources = try? JSONDecoder().decode([Source].self, from: data) else {
            return nil
        }
        return sources.first { $0.id == storyID }?.source
    }
}
