import SwiftUI
import Observation
import Foundation

struct LocationRowView: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.headline)
            Text(location.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
