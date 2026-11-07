import SwiftUI
import Observation
import Foundation

struct ChronologyEntryRowView: View {
    let entry: ChronologyEntry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let date = entry.proposedDate {
                    Text(date, style: .date)
                        .font(.headline)
                } else {
                    Text("Unknown Date")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(entry.source)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(entry.story.title)
                .font(.subheadline)

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 8)
    }
}
