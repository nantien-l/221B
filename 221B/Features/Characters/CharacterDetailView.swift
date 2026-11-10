import SwiftUI
import Observation
import Foundation

struct CharacterDetailView: View {
    let character: Character
    @Environment(DataManager.self) var dataManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Section {
                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if !character.aliases.isEmpty {
                        Text("Aliases: \(character.aliases.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("Category: \(character.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Biography")) {
                    Text(character.biography)
                }

                Section(header: Text("Appearances")) {
                    if !character.appearances.isEmpty {
                        ForEach(character.appearances) { appearance in
                            NavigationLink(value: appearance.story) {
                                AppearanceRowView(appearance: appearance)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(character.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
