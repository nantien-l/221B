import SwiftUI
import Observation
import Foundation

struct StoryLocationRowView: View {
    let storyLocation: StoryLocation

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(storyLocation.story.title)
                    .font(.headline)
                Spacer()
                if let significance = storyLocation.significance {
                    Text(significance.rawValue)
                        .font(.caption)
                        .foregroundColor(significanceColor(significance))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func significanceColor(_ significance: Significance) -> Color {
        switch significance {
        case .central:
            return .green
        case .important:
            return .blue
        case .minor:
            return .orange
        case .incidental:
            return .gray
        }
    }
}
