import SwiftUI
import MapKit

struct PlacesView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var mapMarkers: [PlaceMapMarker] = []
    @State private var mapPosition = MapCameraPosition.region(PlaceMapMarker.unitedKingdom)

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }
    private var places: [Location] {
        dataManager.locations.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    if let error = dataManager.loadError {
                        ContentUnavailableView("Unable to Load Places", systemImage: "exclamationmark.triangle", description: Text(error))
                    } else if places.isEmpty {
                        ContentUnavailableView("No Places Found", systemImage: "map", description: Text("Try a different search."))
                    } else {
                        mapSection
                        directory
                    }
                }
                .frame(maxWidth: 680, alignment: .leading)
                .padding(.horizontal, 24).padding(.top, 32).padding(.bottom, 72)
                .frame(maxWidth: .infinity)
            }
            .background(BookColors.background(for: colorScheme).ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search places")
            .task(id: dataManager.locations.count) { await resolveMapMarkers() }
            .modifier(StoryDestinations())
            .navigationTitle("Places")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE BAKER STREET ARCHIVE")
                .font(.system(.caption, design: .rounded, weight: .semibold)).tracking(1.6).foregroundStyle(accent)
            Text("Places in the stories")
                .font(.system(.largeTitle, design: .serif, weight: .semibold)).foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            Text("Explore selected places connected to the cases. This index is not exhaustive.")
                .font(.subheadline).foregroundStyle(muted).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(24)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }

    private var directory: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("PLACE DIRECTORY").font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(1.4).foregroundStyle(accent).accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(places.count) \(places.count == 1 ? "place" : "places")").font(.footnote).foregroundStyle(muted)
            }
            Link("Source: The Sherlock Holmes Database", destination: URL(string: "https://shdb.guidesite.co.uk/locations/locations-list")!)
                .font(.footnote).foregroundStyle(accent)
            LazyVStack(spacing: 0) {
                ForEach(Array(places.enumerated()), id: \.element.id) { index, location in
                    NavigationLink(value: location) {
                        placeRow(location, showSeparator: index < places.count - 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(paper, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CASE MAP").font(.system(.caption, design: .rounded, weight: .semibold)).tracking(1.4).foregroundStyle(accent)
                    Text("Britain and the cases").font(.system(.title2, design: .serif, weight: .semibold)).foregroundStyle(ink)
                }
                Spacer()
                Text("\(mapMarkers.count) mapped").font(.footnote).foregroundStyle(muted)
            }
            Map(position: $mapPosition) {
                ForEach(mapMarkers) { marker in
                    Annotation(marker.location.name, coordinate: marker.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2).foregroundStyle(accent, paper)
                            .shadow(color: .black.opacity(0.16), radius: 3, y: 2)
                            .accessibilityLabel(marker.location.name)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .including([]), showsTraffic: false))
            .mapControls { MapCompass(); MapScaleView() }
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.24)))
            Text("Markers are resolved by Apple Maps from the archive’s place names. Fictional or ambiguous locations may remain in the directory without a pin.")
                .font(.footnote).foregroundStyle(muted).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func resolveMapMarkers() async {
        let locations = dataManager.locations
        guard !locations.isEmpty else { return }
        var resolved: [PlaceMapMarker] = []
        for location in locations {
            guard !Task.isCancelled else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "\(location.name), \(location.description), United Kingdom"
            request.region = PlaceMapMarker.unitedKingdom
            do {
                let response = try await MKLocalSearch(request: request).start()
                if let item = response.mapItems.first {
                    resolved.append(PlaceMapMarker(location: location, coordinate: item.location.coordinate))
                }
            } catch {
                continue
            }
        }
        guard !Task.isCancelled else { return }
        mapMarkers = resolved
    }

    private func placeRow(_ location: Location, showSeparator: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse").font(.system(size: 21, weight: .light)).foregroundStyle(accent)
                .frame(width: 46, height: 46).background(accent.opacity(0.09), in: Circle()).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(location.name).font(.system(.headline, design: .serif)).foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !location.description.isEmpty {
                    Text(location.description).font(.footnote).foregroundStyle(muted)
                }
            }
            Spacer(minLength: 4)
            if location.isFavorite { Image(systemName: "star.fill").foregroundStyle(accent).accessibilityLabel("Favorite") }
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(muted).accessibilityHidden(true)
        }
        .padding(.horizontal, 20).padding(.vertical, 16).contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showSeparator { Rectangle().fill(accent.opacity(0.14)).frame(height: 1).padding(.leading, 82) }
        }
    }
}

private struct PlaceMapMarker: Identifiable {
    let location: Location
    let coordinate: CLLocationCoordinate2D
    var id: String { location.id }

    static let unitedKingdom = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 54.4, longitude: -2.8),
        span: MKCoordinateSpan(latitudeDelta: 8.8, longitudeDelta: 10.6)
    )
}
