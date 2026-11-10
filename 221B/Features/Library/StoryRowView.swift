import SwiftUI
import Observation
import Foundation

struct StoryRowView: View {
    let story: Story

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(story.title)
                    .font(.headline)
                Text("\(story.collection?.title ?? "Novel") • \(story.publicationYear)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if story.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            if story.isBookmarked {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
