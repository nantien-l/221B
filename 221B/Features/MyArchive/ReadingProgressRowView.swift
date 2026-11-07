import SwiftUI
import Observation
import Foundation

struct ReadingProgressRowView: View {
    let story: Story

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
                    story.readingProgress = 1.0
                }
                .buttonStyle(.bordered)

                Button("Reset Progress") {
                    story.readingProgress = 0.0
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
}
