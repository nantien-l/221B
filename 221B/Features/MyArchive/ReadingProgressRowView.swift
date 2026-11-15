import SwiftUI
import Observation
import Foundation

struct ReadingProgressRowView: View {
    let story: Story
    @Environment(DataManager.self) private var dataManager

    var body: some View {
        VStack(alignment: .leading) {
            Text(story.title)
                .font(.headline)

            HStack {
                Text("Progress: ")
                ProgressView(value: story.readingProgress)
                    .frame(height: 20)
                Text("\(Int(story.readingProgress * 100))%")
            }

            HStack {
                Button("Mark Complete") {
                    dataManager.updateReadingProgress(for: story, to: 1.0)
                }
                .buttonStyle(.bordered)

                Button("Reset Progress") {
                    dataManager.updateReadingProgress(for: story, to: 0.0)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
}
