import SwiftUI
import Observation
import Foundation

struct CollectionRowView: View {
    let collection: Collection

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collection.title)
                    .font(.headline)
                Text("Published: \(collection.year)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(collection.stories.count) stories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
