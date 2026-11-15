import SwiftUI
import Observation
import Foundation

struct AppearanceRowView: View {
    let appearance: Appearance

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(appearance.story.title)
                    .font(.headline)
                Spacer()
                Text(appearance.role?.rawValue.capitalized ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(appearance.isMention.map { $0 ? "Mention" : "Full Appearance" } ?? "Listed in story")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if appearance.role == .protagonist {
                    Text("• Protagonist")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if appearance.role == .antagonist {
                    Text("• Antagonist")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
