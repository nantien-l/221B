import SwiftUI
import Observation
import Foundation

struct CollectionRowView: View {
    let collection: Collection

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collection.title)
                    .font(.bookSection)
                    .foregroundColor(.primary)
                Text("Published: \(collection.year)")
                    .font(.bookMeta)
                    .foregroundColor(.secondary)
                Text("\(collection.stories.count) stories")
                    .font(.bookCaption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
    }
}
