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
    private var visibleMarkers: [PlaceMapMarker] { mapMarkers.filter { marker in places.contains { $0.id == marker.location.id } } }

    var body: some View {
        NavigationStack {
            Group {
                if let error = dataManager.loadError {
                    ContentUnavailableView("Unable to Load Places", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if places.isEmpty {
                    ContentUnavailableView("No Places Found", systemImage: "map", description: Text("Try a different search."))
                } else {
                    fullMap
                }
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

    private var fullMap: some View {
        Map(position: $mapPosition) {
            ForEach(visibleMarkers) { marker in
                Annotation(marker.location.name, coordinate: marker.coordinate) {
                    NavigationLink(value: marker.location) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(accent, paper)
                            .shadow(color: .black.opacity(0.20), radius: 4, y: 2)
                    }
                    .accessibilityLabel(marker.location.name)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .including([]), showsTraffic: false))
        .mapControls { MapCompass(); MapScaleView() }
        .overlay(alignment: .topLeading) { mapHeader }
        .overlay(alignment: .bottomLeading) { mapCaption }
        .ignoresSafeArea(edges: .bottom)
    }

    private var mapHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THE HOLMES GAZETTEER")
                .font(.caption.weight(.semibold)).tracking(1.5).foregroundStyle(accent)
            Text("Britain, case by case")
                .font(.title2.weight(.semibold)).foregroundStyle(ink)
            Text("\(visibleMarkers.count) mapped landmarks")
                .font(.footnote).foregroundStyle(muted)
        }
        .padding(18).padding(.top, 4)
        .background(paper.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
        .padding(20)
    }

    private var mapCaption: some View {
        Text("Selected archive locations · Tap a marker to explore")
            .font(.footnote).foregroundStyle(muted)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(paper.opacity(0.92), in: Capsule())
            .padding(20)
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
