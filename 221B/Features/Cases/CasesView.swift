import SwiftUI

struct CasesView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var activeYear: Int?
    @State private var showsPinnedYear = false

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.29, green: 0.39, blue: 0.30) }
    private var card: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        NavigationStack {
            Group {
                if let timeline = dataManager.caseTimeline {
                    timelineView(timeline)
                } else if let message = dataManager.caseTimelineError ?? dataManager.loadError {
                    ContentUnavailableView("Unable to Load Timeline", systemImage: "exclamationmark.triangle", description: Text(message))
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BookColors.background(for: colorScheme).ignoresSafeArea())
            .modifier(StoryDestinations())
            .navigationTitle("Cases")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func timelineView(_ timeline: CaseTimeline) -> some View {
        let years = Array(Set(timeline.entries.map(\.year))).sorted()
        return GeometryReader { geometry in
          ScrollViewReader { proxy in
            ZStack(alignment: .topLeading) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("THE HOLMES CHRONOLOGY")
                            .font(.caption.weight(.semibold))
                            .tracking(2)
                            .foregroundStyle(accent)
                        Text("A life in cases")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(ink)
                        Text("Travel through Holmes’s cases in the order they are thought to have happened.")
                            .font(.body)
                            .foregroundStyle(muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Dates are interpretations based on Baring-Gould’s chronology.")
                            .font(.footnote)
                            .foregroundStyle(muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Link("View chronology source", destination: timeline.source)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(accent)
                    }
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 28)

                    Text("SCROLL TO EXPLORE")
                        .font(.caption2.weight(.semibold))
                        .tracking(1.5)
                        .foregroundStyle(muted)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)

                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(years.enumerated()), id: \.element) { yearIndex, year in
                            let entries = timeline.entries.filter { $0.year == year }
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                    timelineCard(entry, showYear: index == 0,
                                                 isLeft: yearIndex.isMultiple(of: 2),
                                                 isWide: geometry.size.width >= 650,
                                                 sideWidth: max(0, (min(geometry.size.width - 48, 720) - 14) / 2),
                                                 viewportCenter: geometry.frame(in: .global).midY,
                                                 viewportHeight: geometry.size.height)
                                        .id(entry.id)
                                }
                            }
                            .padding(.horizontal, 24)
                            .frame(maxWidth: 720, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(yearWash(for: yearIndex))
                            .background(GeometryReader { proxy in
                                Color.clear.preference(key: CaseYearOffsetKey.self, value: [year: proxy.frame(in: .named("caseTimeline")).minY])
                            })
                            .id(year)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 35)
            }
            .coordinateSpace(name: "caseTimeline")
            .onAppear { activeYear = years.first }
            .onPreferenceChange(CaseYearOffsetKey.self) { offsets in
                let passed = offsets.filter { $0.value <= 150 }.max { $0.value < $1.value }?.key
                let nearest = offsets.min { abs($0.value - 150) < abs($1.value - 150) }?.key
                let year = passed ?? nearest ?? activeYear
                activeYear = year
                if let firstYear = years.first, let firstOffset = offsets[firstYear] {
                    showsPinnedYear = year != firstYear || firstOffset < 145
                }
            }
            .overlay(alignment: .topLeading) {
                if let activeYear, showsPinnedYear {
                    Text(String(activeYear))
                        .font(.system(size: 44, weight: .semibold, design: .serif))
                        .foregroundStyle(ink)
                        .padding(.horizontal, 18).padding(.vertical, 8)
                        .background(BookColors.background(for: colorScheme).opacity(0.92), in: Capsule())
                        .overlay(Capsule().strokeBorder(accent.opacity(0.16)))
                        .padding(.leading, 24).padding(.top, 14)
                        .allowsHitTesting(false)
                        .accessibilityLabel("Current year \(String(activeYear))")
                }
            }
            .overlay(alignment: .topTrailing) {
                yearIndex(years: years, proxy: proxy)
                    .padding(.trailing, 10).padding(.top, 116)
            }
            }
          }
        }
    }

    private func timelineCard(_ entry: CaseTimelineEntry, showYear: Bool, isLeft: Bool, isWide: Bool, sideWidth: CGFloat, viewportCenter: CGFloat, viewportHeight: CGFloat) -> some View {
        let shouldReduceMotion = reduceMotion
        return HStack(alignment: .top, spacing: 0) {
            if isWide {
                if isLeft {
                    cardContent(entry, showYear: showYear, isLeft: isLeft && isWide, viewportCenter: viewportCenter, viewportHeight: viewportHeight, shouldReduceMotion: shouldReduceMotion)
                        .padding(.trailing, 22)
                        .frame(width: sideWidth, alignment: .trailing)
                } else {
                    Color.clear.frame(width: sideWidth).accessibilityHidden(true)
                }
            }

            timelineSpine

            if !isWide || !isLeft {
                cardContent(entry, showYear: showYear, isLeft: isLeft && isWide, viewportCenter: viewportCenter, viewportHeight: viewportHeight, shouldReduceMotion: shouldReduceMotion)
                    .padding(.leading, isWide ? 22 : 16)
                    .frame(width: isWide ? sideWidth : nil, alignment: .leading)
                    .frame(maxWidth: isWide ? nil : .infinity, alignment: .leading)
            } else {
                Color.clear.frame(width: sideWidth).accessibilityHidden(true)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var timelineSpine: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(accent.opacity(0.35)).frame(width: 1).frame(maxHeight: .infinity)
            Circle().fill(accent).frame(width: 11, height: 11).padding(.top, 14)
        }
        .frame(width: 14)
        .accessibilityHidden(true)
    }

    private func yearWash(for index: Int) -> Color {
        if colorScheme == .dark {
            return index.isMultiple(of: 2) ? Color(red: 0.38, green: 0.48, blue: 0.39).opacity(0.10) : Color(red: 0.52, green: 0.43, blue: 0.29).opacity(0.08)
        }
        return index.isMultiple(of: 2) ? Color(red: 0.42, green: 0.52, blue: 0.43).opacity(0.045) : Color(red: 0.58, green: 0.47, blue: 0.29).opacity(0.038)
    }

    private func yearIndex(years: [Int], proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 1) {
            ForEach(years, id: \.self) { year in
                Button(String(year)) {
                    if reduceMotion { proxy.scrollTo(year, anchor: .top) }
                    else { withAnimation(.easeInOut(duration: 0.38)) { proxy.scrollTo(year, anchor: .top) } }
                }
                .font(.system(size: 10, weight: year == activeYear ? .bold : .regular, design: .rounded))
                .foregroundStyle(year == activeYear ? accent : muted)
                .frame(width: 38, height: 18)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
                .background(year == activeYear ? accent.opacity(0.12) : .clear, in: Capsule())
                .accessibilityLabel("Go to \(String(year))")
            }
        }
        .padding(.vertical, 6)
    }

    private func cardContent(_ entry: CaseTimelineEntry, showYear: Bool, isLeft: Bool, viewportCenter: CGFloat, viewportHeight: CGFloat, shouldReduceMotion: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if showYear {
                Text(String(entry.year))
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(ink)
                    .accessibilityLabel("Estimated year \(String(entry.year))")
            }
            NavigationLink(value: entry.story) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CASE \(String(format: "%02d", entry.order))")
                        .font(.caption2.weight(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(accent)
                    Text(entry.story.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(entry.story.collection?.title ?? "Novel")
                        .font(.subheadline)
                        .foregroundStyle(muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Label("Explore case", systemImage: "arrow.right")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(accent)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(card, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(accent.opacity(0.18)))
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 28)
        .visualEffect { content, geometry in
            let distance = abs(geometry.frame(in: .global).midY - viewportCenter)
            let focus = max(0, 1 - distance / max(viewportHeight * 0.45, 1))
            let scale = shouldReduceMotion ? 1 : 0.38 + 0.76 * focus
            return content
                .scaleEffect(scale, anchor: isLeft ? .trailing : .leading)
                .opacity(shouldReduceMotion ? 1 : 0.45 + 0.55 * focus)
        }
    }
}

private struct CaseYearOffsetKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) { value.merge(nextValue(), uniquingKeysWith: { _, new in new }) }
}
