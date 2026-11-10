import SwiftUI

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

    private var theme: ReaderTheme { ReaderTheme(rawValue: themeName) ?? .automatic }

    var body: some View {
        let colors = theme.colors(for: colorScheme)
        ScrollView {
            if let errorMessage {
                ContentUnavailableView("Unable to Load Text", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                    .foregroundStyle(colors.ink)
                    .padding(.top, 60)
            } else if paragraphs.isEmpty {
                ProgressView().padding(.top, 80)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
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

                    ForEach(paragraphs.indices, id: \.self) { index in
                        Text(paragraphs[index])
                            .font(.system(size: fontSize * textScale, design: .serif))
                            .lineSpacing(fontSize * 0.32)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(.bottom, fontSize * 0.85)
                    }

                    if let sourceURL {
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
                .padding(.bottom, 80)
                .frame(maxWidth: .infinity)
            }
        }
        .background(colors.background.ignoresSafeArea())
        .navigationTitle(story.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
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
                paragraphs = text.components(separatedBy: "\n\n")
                    .map { block in
                        block.components(separatedBy: .newlines)
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .joined(separator: " ")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .filter { !$0.isEmpty }
                sourceURL = repository.source(for: story.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
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
