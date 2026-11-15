import SwiftUI
import WebKit

// MARK: - WKWebView wrapper

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.error = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.error = error
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.error = error
        }
    }
}

// MARK: - Museum tab

struct MuseumView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let museumURL = URL(string: "https://www.sherlock-holmes.co.uk")!

    @State private var isLoading = false
    @State private var loadError: Error?

    private var ink: Color {
        colorScheme == .dark
            ? Color(red: 0.91, green: 0.89, blue: 0.83)
            : Color(red: 0.18, green: 0.20, blue: 0.17)
    }
    private var muted: Color {
        colorScheme == .dark
            ? Color(red: 0.69, green: 0.69, blue: 0.62)
            : Color(red: 0.40, green: 0.42, blue: 0.35)
    }
    private var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.65, green: 0.73, blue: 0.57)
            : Color(red: 0.29, green: 0.39, blue: 0.30)
    }
    private var paper: Color {
        colorScheme == .dark
            ? Color(red: 0.17, green: 0.18, blue: 0.16)
            : Color(red: 0.99, green: 0.98, blue: 0.95)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BookColors.background(for: colorScheme).ignoresSafeArea()

                if let error = loadError {
                    ContentUnavailableView(
                        "Cannot Connect",
                        systemImage: "wifi.slash",
                        description: Text(error.localizedDescription)
                    )
                    .foregroundStyle(ink)
                } else {
                    WebView(url: museumURL, isLoading: $isLoading, error: $loadError)
                        .ignoresSafeArea(edges: .bottom)
                        .overlay(alignment: .top) {
                            if isLoading { ProgressView().tint(accent) }
                        }
                }
            }
            .navigationTitle("Museum")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("THE SHERLOCK HOLMES MUSEUM")
                            .font(.caption2.weight(.semibold))
                            .tracking(1.2)
                            .foregroundStyle(accent)
                        Text("221b Baker Street · London")
                            .font(.caption2)
                            .foregroundStyle(muted)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Link(destination: museumURL) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                    .foregroundStyle(accent)
                }
            }
        }
    }
}
