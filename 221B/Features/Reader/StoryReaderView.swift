import SwiftUI
import UIKit

private enum ReaderTheme: String, CaseIterable, Identifiable {
    case automatic, paper, sepia, night

    var id: String { rawValue }
    var label: String {
        switch self {
        case .automatic: "Auto"
        case .paper: "Paper"
        case .sepia: "Sepia"
        case .night: "Night"
        }
    }

    func colors(for scheme: ColorScheme) -> (background: Color, ink: Color, secondary: Color) {
        switch self == .automatic ? (scheme == .dark ? .night : .paper) : self {
        case .automatic, .paper:
            (Color(red: 0.985, green: 0.978, blue: 0.961), Color(red: 0.16, green: 0.15, blue: 0.14), Color(red: 0.42, green: 0.40, blue: 0.37))
        case .sepia:
            (Color(red: 0.93, green: 0.89, blue: 0.81), Color(red: 0.25, green: 0.20, blue: 0.15), Color(red: 0.46, green: 0.37, blue: 0.29))
        case .night:
            (Color(red: 0.10, green: 0.105, blue: 0.115), Color(red: 0.88, green: 0.87, blue: 0.84), Color(red: 0.66, green: 0.65, blue: 0.63))
        }
    }
}

struct StoryReaderView: View {
    let story: Story
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .body) private var textScale = 1.0
    @AppStorage("reader.fontSize") private var fontSize = 19.0
    @AppStorage("reader.theme") private var themeName = ReaderTheme.automatic.rawValue
    @State private var paragraphs: [String] = []
    @State private var errorMessage: String?
    @State private var sourceURL: URL?
    @State private var showingSettings = false
    @State private var showingContents = false
    @State private var chapters: [ReaderChapter] = []
    @State private var pages: [ReaderPage] = []
    @State private var selectedChapterID = 0
    @State private var selectedPageID = 0
    @State private var showsTwoPages = false

    private var theme: ReaderTheme { ReaderTheme(rawValue: themeName) ?? .automatic }

    var body: some View {
        let colors = theme.colors(for: colorScheme)
        Group {
            if let errorMessage {
                ContentUnavailableView("Unable to Load Text", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                    .foregroundStyle(colors.ink)
            } else if pages.isEmpty {
                ProgressView()
            } else {
                GeometryReader { geometry in
                    let pageStarts = Array(stride(from: 0, to: pages.count, by: showsTwoPages ? 2 : 1))
                    Group {
                        if showsTwoPages {
                            TabView(selection: $selectedPageID) {
                                ForEach(pageStarts, id: \.self) { start in
                                    readerSpread(startingAt: start, colors: colors)
                                        .tag(start)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        } else {
                            BookPageCurlView(selection: $selectedPageID, pages: pages) { page in
                                AnyView(readerPage(page, colors: colors))
                            }
                        }
                    }
                    .overlay { if showsTwoPages { pageTurnZones } }
                    .overlay(alignment: .bottom) { pageCounter }
                    .onAppear { updateLayout(width: geometry.size.width, height: geometry.size.height) }
                    .onChange(of: geometry.size) { _, size in
                        updateLayout(width: size.width, height: size.height)
                    }
                }
            }
        }
        .sheet(isPresented: $showingContents) {
            tableOfContents { chapter in
                selectedChapterID = chapter.id
                let page = pages.first(where: { $0.chapterID == chapter.id })?.id ?? 0
                selectedPageID = showsTwoPages ? page - page % 2 : page
                showingContents = false
            }
        }
        .onChange(of: selectedPageID) { _, pageID in
            if let page = pages.first(where: { $0.id == pageID }) {
                selectedChapterID = page.chapterID
            }
        }
        .background(colors.background.ignoresSafeArea())
        .navigationTitle(story.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingContents = true
                } label: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel("Table of contents")
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    moveToAdjacentChapter(-1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(selectedChapterID == 0 || chapters.count < 2)
                .accessibilityLabel("Previous chapter")

                Button {
                    moveToAdjacentChapter(1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(selectedChapterID >= chapters.count - 1 || chapters.count < 2)
                .accessibilityLabel("Next chapter")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Text("Aa").font(.system(size: 17, weight: .medium, design: .serif))
                }
                .accessibilityLabel("Reading appearance")
                .popover(isPresented: $showingSettings) {
                    readerSettings
                }
            }
        }
        .task {
            guard paragraphs.isEmpty, errorMessage == nil else { return }
            do {
                let repository = StoryTextRepository()
                let text = try repository.loadText(for: story.id)
                let readingText = removeFrontMatter(from: text)
                paragraphs = readingText.components(separatedBy: "\n\n")
                    .map { block in
                        block.components(separatedBy: .newlines)
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .joined(separator: " ")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .filter { !$0.isEmpty }
                chapters = ReaderChapter.make(from: paragraphs)
                pages = ReaderPage.make(from: paragraphs, chapters: chapters)
                sourceURL = repository.source(for: story.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func titlePage(colors: (background: Color, ink: Color, secondary: Color)) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(story.collection?.title.uppercased() ?? "A SHERLOCK HOLMES NOVEL")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(colors.secondary)
            Text(story.title)
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            Text("ARTHUR CONAN DOYLE")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.3)
                .foregroundStyle(colors.secondary)
            Rectangle()
                .fill(colors.secondary.opacity(0.35))
                .frame(width: 42, height: 1)
                .padding(.top, 8)
        }
        .padding(.bottom, 38)
        .accessibilityElement(children: .combine)
    }

    /// Gutenberg transcriptions often place a full contents list before the actual text.
    /// The reader must not turn that unstructured list into book pages.
    private func removeFrontMatter(from text: String) -> String {
        guard let contents = text.range(of: "contents", options: .caseInsensitive) else { return text }
        let afterContents = contents.upperBound..<text.endIndex

        // Most novel files repeat the title immediately before the real opening.
        if let listedTitle = text.range(of: story.title, options: [.caseInsensitive], range: afterContents) {
            let afterListedTitle = listedTitle.upperBound..<text.endIndex
            if let realTitle = text.range(of: story.title, options: [.caseInsensitive], range: afterListedTitle) {
                return String(text[realTitle.upperBound...])
            }
        }

        // Editions without a repeated title (for example some Gutenberg novels)
        // distinguish the real first chapter with a trailing period.
        let chapterMarkers = ["chapter 1.", "chapter i."]
        for marker in chapterMarkers {
            if let firstChapter = text.range(of: marker, options: .caseInsensitive, range: afterContents) {
                return String(text[firstChapter.lowerBound...])
            }
        }
        return text
    }

    private func chapterHeading(_ chapter: ReaderChapter, colors: (background: Color, ink: Color, secondary: Color)) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHAPTER \(String(format: "%02d", chapter.id + 1))")
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(colors.secondary)
            Text(chapter.title)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(colors.ink)
        }
        .padding(.top, chapter.id == 0 ? 0 : 52)
        .padding(.bottom, 20)
    }

    private func readerPage(_ page: ReaderPage, colors: (background: Color, ink: Color, secondary: Color)) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if page.id == 0 { titlePage(colors: colors) }
                if let chapter = chapters.first(where: { $0.id == page.chapterID }), page.startsChapter {
                    chapterHeading(chapter, colors: colors)
                }
                ForEach(page.paragraphs.indices, id: \.self) { index in
                    Text(page.paragraphs[index])
                        .font(.system(size: fontSize * textScale, design: .serif))
                        .lineSpacing(fontSize * 0.32)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.bottom, fontSize * 0.85)
                }
                if page.id == pages.last?.id, let sourceURL {
                    Link("Source: Project Gutenberg", destination: sourceURL)
                        .font(.footnote)
                        .foregroundStyle(colors.secondary)
                        .padding(.top, 24)
                }
            }
            .foregroundStyle(colors.ink)
            .frame(maxWidth: 620, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, 48)
            .padding(.bottom, 90)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
        .clipped()
    }

    private func readerSpread(startingAt start: Int, colors: (background: Color, ink: Color, secondary: Color)) -> some View {
        HStack(spacing: 0) {
            readerPage(pages[start], colors: colors)
                .frame(maxWidth: .infinity)
            if showsTwoPages, start + 1 < pages.count {
                Rectangle()
                    .fill(colors.secondary.opacity(0.16))
                    .frame(width: 1)
                    .padding(.vertical, 22)
                readerPage(pages[start + 1], colors: colors)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(colors.background)
    }

    private var pageTurnZones: some View {
        HStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { turnPages(by: -1) }
                .accessibilityLabel("Previous page")
            Spacer(minLength: 0)
                .allowsHitTesting(false)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { turnPages(by: 1) }
                .accessibilityLabel("Next page")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 0)
        .overlay(alignment: .leading) { Color.clear.frame(width: 74) }
        .overlay(alignment: .trailing) { Color.clear.frame(width: 74) }
    }

    private var pageCounter: some View {
        let first = selectedPageID + 1
        let last = min(selectedPageID + (showsTwoPages ? 2 : 1), pages.count)
        return Text(first == last ? "\(first) / \(pages.count)" : "\(first)–\(last) / \(pages.count)")
            .font(.caption.monospacedDigit())
            .foregroundStyle(theme.colors(for: colorScheme).secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(theme.colors(for: colorScheme).background.opacity(0.9), in: Capsule())
            .padding(.bottom, 12)
            .allowsHitTesting(false)
    }

    private func turnPages(by direction: Int) {
        let step = showsTwoPages ? 2 : 1
        let upperBound = showsTwoPages ? max(0, ((pages.count - 1) / 2) * 2) : max(0, pages.count - 1)
        let target = min(max(selectedPageID + direction * step, 0), upperBound)
        guard target != selectedPageID else { return }
        withAnimation(.easeInOut(duration: 0.28)) { selectedPageID = target }
    }

    private func updateLayout(width: CGFloat, height: CGFloat) {
        let shouldShowTwo = width > height && width >= 700
        guard showsTwoPages != shouldShowTwo else { return }
        showsTwoPages = shouldShowTwo
        if shouldShowTwo { selectedPageID -= selectedPageID % 2 }
    }

    private func tableOfContents(onSelect: @escaping (ReaderChapter) -> Void) -> some View {
        NavigationStack {
            List(chapters) { chapter in
                Button {
                    onSelect(chapter)
                } label: {
                    HStack(spacing: 14) {
                        Text(String(format: "%02d", chapter.id + 1))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.colors(for: colorScheme).secondary)
                            .frame(width: 28, alignment: .leading)
                        Text(chapter.title)
                            .font(.system(.body, design: .serif).weight(chapter.id == selectedChapterID ? .semibold : .regular))
                        Spacer()
                        if chapter.id == selectedChapterID {
                            Image(systemName: "bookmark.fill")
                                .font(.caption)
                                .foregroundStyle(theme.colors(for: colorScheme).secondary)
                        }
                    }
                    .foregroundStyle(theme.colors(for: colorScheme).ink)
                }
            }
            .navigationTitle("Contents")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingContents = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func moveToAdjacentChapter(_ direction: Int) {
        let nextID = min(max(selectedChapterID + direction, 0), chapters.count - 1)
        guard nextID != selectedChapterID else { return }
        selectedChapterID = nextID
        let page = pages.first(where: { $0.chapterID == nextID })?.id ?? selectedPageID
        selectedPageID = showsTwoPages ? page - page % 2 : page
    }

    private var readerSettings: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Reading Appearance").font(.headline)
            HStack {
                Text("Text Size")
                Spacer()
                Button {
                    fontSize = max(15, fontSize - 1)
                } label: { Image(systemName: "minus") }
                    .accessibilityLabel("Decrease text size")
                    .disabled(fontSize <= 15)
                Text("\(Int(fontSize))")
                    .monospacedDigit()
                    .frame(width: 28)
                Button {
                    fontSize = min(30, fontSize + 1)
                } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Increase text size")
                    .disabled(fontSize >= 30)
            }
            Picker("Theme", selection: $themeName) {
                ForEach(ReaderTheme.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(20)
        .frame(minWidth: 290, maxWidth: 340)
        #if !os(macOS)
        .presentationCompactAdaptation(.popover)
        #endif
    }
}

private struct ReaderChapter: Identifiable {
    let id: Int
    let title: String
    let startIndex: Int

    static func make(from paragraphs: [String]) -> [ReaderChapter] {
        let detected = paragraphs.enumerated().compactMap { index, paragraph -> (Int, String)? in
            let line = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = line.lowercased()
            guard lower.hasPrefix("chapter ") || lower.hasPrefix("part ") else { return nil }
            let title = line.replacingOccurrences(of: "\n", with: " ")
            guard title.count < 180 else { return nil }
            return (index, title)
        }
        guard !detected.isEmpty else { return [ReaderChapter(id: 0, title: "Beginning", startIndex: 0)] }
        return detected.enumerated().map { offset, item in
            ReaderChapter(id: offset, title: item.1, startIndex: item.0)
        }
    }
}

private struct ReaderPage: Identifiable {
    let id: Int
    let chapterID: Int
    let startsChapter: Bool
    let paragraphs: [String]

    static func make(from paragraphs: [String], chapters: [ReaderChapter]) -> [ReaderPage] {
        let chapterByStart = Dictionary(uniqueKeysWithValues: chapters.map { ($0.startIndex, $0.id) })
        var pages: [ReaderPage] = []
        var pending: [String] = []
        var currentChapterID = chapters.first?.id ?? 0
        var startsChapter = true

        func appendPage() {
            guard !pending.isEmpty else { return }
            pages.append(ReaderPage(id: pages.count, chapterID: currentChapterID, startsChapter: startsChapter, paragraphs: pending))
            pending.removeAll()
            startsChapter = false
        }

        for (index, paragraph) in paragraphs.enumerated() {
            if let chapterID = chapterByStart[index] {
                appendPage()
                currentChapterID = chapterID
                startsChapter = true
                continue
            }
            pending.append(paragraph)
            // Two source paragraphs keep each iPad page comfortable at the largest supported type size.
            if pending.count == 2 { appendPage() }
        }
        appendPage()
        return pages.isEmpty ? [ReaderPage(id: 0, chapterID: 0, startsChapter: true, paragraphs: paragraphs)] : pages
    }
}

/// UIKit supplies the physical page-curl transition that SwiftUI's page-style TabView does not offer.
private struct BookPageCurlView: UIViewControllerRepresentable {
    @Binding var selection: Int
    let pages: [ReaderPage]
    let content: (ReaderPage) -> AnyView

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [.spineLocation: NSNumber(value: UIPageViewController.SpineLocation.min.rawValue)]
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        context.coordinator.pageController = controller
        context.coordinator.visibleIndex = selection
        controller.setViewControllers([context.coordinator.controller(at: selection)], direction: .forward, animated: false)
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        guard context.coordinator.visibleIndex != selection else { return }
        let direction: UIPageViewController.NavigationDirection = selection >= context.coordinator.visibleIndex ? .forward : .reverse
        controller.setViewControllers([context.coordinator.controller(at: selection)], direction: direction, animated: true)
        context.coordinator.visibleIndex = selection
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: BookPageCurlView
        weak var pageController: UIPageViewController?
        var visibleIndex = 0
        private var pendingIndex: Int?

        init(_ parent: BookPageCurlView) {
            self.parent = parent
        }

        func controller(at index: Int) -> UIViewController {
            let safeIndex = min(max(index, 0), parent.pages.count - 1)
            let hosting = UIHostingController(rootView: parent.content(parent.pages[safeIndex]))
            hosting.view.isOpaque = true
            hosting.view.tag = safeIndex
            return hosting
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            guard index > 0 else { return nil }
            pendingIndex = index - 1
            return controller(at: index - 1)
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            guard index + 1 < parent.pages.count else { return nil }
            pendingIndex = index + 1
            return controller(at: index + 1)
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let index = pageViewController.viewControllers?.first?.view.tag else { return }
            visibleIndex = index
            parent.selection = index
            pendingIndex = nil
        }
    }
}
