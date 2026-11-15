import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header
                stories
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 24).padding(.top, 38).padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .background(BookColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(location.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Rectangle().frame(width: 30, height: 1)
                Text("PLACE FILE").font(.system(.caption, design: .rounded, weight: .semibold)).tracking(2)
                Rectangle().frame(width: 30, height: 1)
            }.foregroundStyle(accent)
            Image(systemName: "mappin.and.ellipse").font(.system(size: 34, weight: .ultraLight)).foregroundStyle(accent)
                .frame(width: 76, height: 76).background(accent.opacity(0.09), in: Circle()).accessibilityHidden(true)
            Text(location.name).font(.system(.largeTitle, design: .serif, weight: .semibold)).foregroundStyle(ink)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            if !location.description.isEmpty {
                Text(location.description).font(.system(.subheadline, design: .serif)).foregroundStyle(muted).multilineTextAlignment(.center)
            }
            Button { dataManager.toggleFavorite(for: location) } label: {
                Label(location.isFavorite ? "Saved to favourites" : "Add to favourites", systemImage: location.isFavorite ? "star.fill" : "star")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(location.isFavorite ? paper : accent)
                    .padding(.horizontal, 15).padding(.vertical, 9)
                    .background(location.isFavorite ? accent : accent.opacity(0.09), in: Capsule())
            }
            .buttonStyle(.plain)
            if location.id.hasPrefix("shdb-location-"),
               let source = URL(string: "https://shdb.guidesite.co.uk/locations/locations-view?lcid=\(location.id.dropFirst("shdb-location-".count))") {
                Link("View source", destination: source).font(.footnote).foregroundStyle(accent).padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity).padding(.horizontal, 22).padding(.vertical, 34)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }

    private var stories: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("RELATED STORIES").font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(1.5).foregroundStyle(accent).accessibilityAddTraits(.isHeader)
                Spacer()
                if !location.storyLocations.isEmpty {
                    Text("\(location.storyLocations.count) \(location.storyLocations.count == 1 ? "story" : "stories")")
                        .font(.footnote).foregroundStyle(muted)
                }
            }
            Text("Stories listed by the source; this index may be incomplete.")
                .font(.footnote).foregroundStyle(muted).fixedSize(horizontal: false, vertical: true)
            if location.storyLocations.isEmpty {
                Text("No related stories available yet.").font(.subheadline).foregroundStyle(muted)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(location.storyLocations.enumerated()), id: \.element.id) { index, relation in
                        NavigationLink(value: relation.story) {
                            HStack(spacing: 16) {
                                Image(systemName: "book.closed").font(.system(size: 18, weight: .light)).foregroundStyle(accent)
                                    .frame(width: 42, height: 42).background(accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 9)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(relation.story.title).font(.system(.headline, design: .serif)).foregroundStyle(ink).fixedSize(horizontal: false, vertical: true)
                                    Text(relation.story.collection?.title ?? "Novel").font(.footnote).foregroundStyle(muted)
                                }
                                Spacer(minLength: 4)
                                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(muted).accessibilityHidden(true)
                            }
                            .padding(.horizontal, 20).padding(.vertical, 16).contentShape(Rectangle())
                            .overlay(alignment: .bottom) {
                                if index < location.storyLocations.count - 1 {
                                    Rectangle().fill(accent.opacity(0.14)).frame(height: 1).padding(.leading, 78)
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }
                .background(paper, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
            }
        }
    }
}
