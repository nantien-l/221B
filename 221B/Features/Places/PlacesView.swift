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
                            .foregroundStyle(marker.isApproximate ? Color(red: 0.55, green: 0.35, blue: 0.12) : accent, paper)
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
            Text("\(visibleMarkers.count) of \(dataManager.locations.count) catalogued locations mapped")
                .font(.footnote).foregroundStyle(muted)
        }
        .padding(18).padding(.top, 4)
        .background(paper.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
        .padding(20)
    }

    private var mapCaption: some View {
        Text("SHDB location index · Approximate pins are shown in amber")
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
            if let marker = await resolvedMarker(for: location) {
                resolved.append(marker)
            }
        }
        guard !Task.isCancelled else { return }
        mapMarkers = resolved
    }

    private func resolvedMarker(for location: Location) async -> PlaceMapMarker? {
        for query in ["\(location.name), \(location.description)", location.description, location.name] where !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = PlaceMapMarker.unitedKingdom
            if let response = try? await MKLocalSearch(request: request).start(), let item = response.mapItems.first {
                return PlaceMapMarker(location: location, coordinate: item.location.coordinate, isApproximate: false)
            }
        }
        let coordinate = PlaceMapMarker.approximateCoordinates[location.id]
            ?? PlaceMapMarker.regionalFallback(for: location)
        return PlaceMapMarker(location: location, coordinate: coordinate, isApproximate: true)
    }
}

private struct PlaceMapMarker: Identifiable {
    let location: Location
    let coordinate: CLLocationCoordinate2D
    let isApproximate: Bool
    var id: String { location.id }

    static let unitedKingdom = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 54.4, longitude: -2.8),
        span: MKCoordinateSpan(latitudeDelta: 8.8, longitudeDelta: 10.6)
    )

    /// Regional fallbacks for fictional or deliberately vague source entries. Amber
    /// pins communicate that these are not precise real-world addresses.
    static let approximateCoordinates: [String: CLLocationCoordinate2D] = [
        "shdb-location-1": .init(latitude: 51.52, longitude: -0.16),
        "shdb-location-2": .init(latitude: 51.52, longitude: -0.11),
        "shdb-location-25": .init(latitude: 51.50, longitude: -1.20),
        "shdb-location-21": .init(latitude: 51.31, longitude: 1.10),
        "shdb-location-19": .init(latitude: 50.57, longitude: -3.93),
        "shdb-location-22": .init(latitude: 50.98, longitude: -0.45),
        "shdb-location-6": .init(latitude: 51.91, longitude: -2.58),
        "shdb-location-5": .init(latitude: 51.50, longitude: -0.13),
        "shdb-location-16": .init(latitude: 51.24, longitude: -0.21),
        "shdb-location-14": .init(latitude: 52.68, longitude: 0.95),
        "shdb-location-10": .init(latitude: 51.52, longitude: -1.12),
        "shdb-location-11": .init(latitude: 51.51, longitude: -0.13),
        "shdb-location-15": .init(latitude: 50.96, longitude: -0.54),
        "shdb-location-13": .init(latitude: 50.57, longitude: -3.93),
        "shdb-location-17": .init(latitude: 51.25, longitude: -0.76),
        "shdb-location-4": .init(latitude: 51.51, longitude: -0.14),
        "shdb-location-20": .init(latitude: 53.10, longitude: -1.73),
        "shdb-location-18": .init(latitude: 46.71, longitude: 8.17),
        "shdb-location-3": .init(latitude: 40.76, longitude: -111.89),
        "shdb-location-26": .init(latitude: 51.26, longitude: -1.31),
        "shdb-location-9": .init(latitude: 51.21, longitude: -0.67),
        "shdb-location-8": .init(latitude: 51.51, longitude: -0.08),
        "shdb-location-7": .init(latitude: 51.46, longitude: 0.01),
        "shdb-location-12": .init(latitude: 51.06, longitude: -1.32),
        "shdb-location-24": .init(latitude: 52.14, longitude: -0.47),
        "shdb-location-23": .init(latitude: 51.37, longitude: -0.37)
    ]

    static func regionalFallback(for location: Location) -> CLLocationCoordinate2D {
        let text = "\(location.name) \(location.description)".lowercased()
        let regions: [(String, CLLocationCoordinate2D)] = [
            ("london", .init(latitude: 51.507, longitude: -0.128)),
            ("surrey", .init(latitude: 51.25, longitude: -0.40)),
            ("sussex", .init(latitude: 50.95, longitude: -0.25)),
            ("kent", .init(latitude: 51.20, longitude: 0.65)),
            ("norfolk", .init(latitude: 52.68, longitude: 0.95)),
            ("suffolk", .init(latitude: 52.18, longitude: 1.00)),
            ("hampshire", .init(latitude: 51.05, longitude: -1.30)),
            ("berkshire", .init(latitude: 51.45, longitude: -1.00)),
            ("devon", .init(latitude: 50.72, longitude: -3.75)),
            ("derbyshire", .init(latitude: 53.12, longitude: -1.65)),
            ("cambridgeshire", .init(latitude: 52.21, longitude: 0.12)),
            ("oxfordshire", .init(latitude: 51.75, longitude: -1.26)),
            ("switzerland", .init(latitude: 46.80, longitude: 8.23)),
            ("france", .init(latitude: 46.23, longitude: 2.21)),
            ("belgium", .init(latitude: 50.85, longitude: 4.35)),
            ("utah", .init(latitude: 40.76, longitude: -111.89))
        ]
        return regions.first(where: { text.contains($0.0) })?.1
            ?? CLLocationCoordinate2D(latitude: 54.4, longitude: -2.8)
    }
}
