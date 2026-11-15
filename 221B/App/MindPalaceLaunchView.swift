import SwiftUI

struct MindPalaceLaunchView: View {
    var onFinished: () -> Void

    @State private var appearRing = false
    @State private var appearSilhouette = false
    @State private var appearTitle = false
    @State private var appearSubtitle = false
    @State private var appearQuote = false
    @State private var pulseGlow = false

    private let bgDark = Color(red: 0.05, green: 0.065, blue: 0.055)
    private let bgCenter = Color(red: 0.09, green: 0.12, blue: 0.10)
    private let gold = Color(red: 0.86, green: 0.75, blue: 0.52)
    private let sage = Color(red: 0.65, green: 0.74, blue: 0.58)
    private let cream = Color(red: 0.95, green: 0.93, blue: 0.88)
    private let muted = Color(red: 0.62, green: 0.65, blue: 0.58)

    var body: some View {
        ZStack {
            // Background: Atmospheric deep dark mystery gradient
            RadialGradient(
                colors: [bgCenter, bgDark],
                center: .center,
                startRadius: 40,
                endRadius: 540
            )
            .ignoresSafeArea()

            // Mind Palace Architectural Blueprint Rings
            concentricRings
                .opacity(appearRing ? 0.38 : 0)
                .scaleEffect(appearRing ? 1.0 : 0.82)
                .animation(.easeOut(duration: 1.2), value: appearRing)

            // Central Pure Typography & Silhouette
            VStack(spacing: 24) {
                // Sherlock Holmes Iconic Silhouette Emblem
                ZStack {
                    // Outer rotating decorative dashed ring
                    Circle()
                        .stroke(sage.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [4, 6]))
                        .frame(width: 154, height: 154)
                        .rotationEffect(.degrees(pulseGlow ? 360 : 0))
                        .animation(.linear(duration: 26).repeatForever(autoreverses: false), value: pulseGlow)

                    // Solid gold border ring
                    Circle()
                        .strokeBorder(gold.opacity(0.38), lineWidth: 1.5)
                        .frame(width: 132, height: 132)
                        .background(
                            Circle()
                                .fill(bgDark.opacity(0.75))
                                .shadow(color: gold.opacity(pulseGlow ? 0.35 : 0.15), radius: 18)
                        )

                    // Sherlock Holmes Silhouette Profile
                    Image("SherlockSilhouette")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 86)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [cream, gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: gold.opacity(pulseGlow ? 0.55 : 0.25), radius: 12)
                        .offset(x: 3) // optical centering for the pipe
                }
                .opacity(appearSilhouette ? 1 : 0)
                .scaleEffect(appearSilhouette ? 1 : 0.72)
                .animation(.spring(response: 0.85, dampingFraction: 0.7), value: appearSilhouette)

                // 221B Title & Branding
                VStack(spacing: 8) {
                    Text("221B")
                        .font(.system(size: 72, weight: .light, design: .serif))
                        .tracking(10)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [cream, gold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                        .opacity(appearTitle ? 1 : 0)
                        .offset(y: appearTitle ? 0 : 16)
                        .animation(.easeOut(duration: 0.85).delay(0.25), value: appearTitle)

                    // Ornamental Diamond Divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, gold.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 52, height: 1)

                        Image(systemName: "rhombus.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(gold)

                        Rectangle()
                            .fill(LinearGradient(colors: [gold.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 52, height: 1)
                    }
                    .opacity(appearSubtitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: appearSubtitle)

                    // M I N D   P A L A C E
                    Text("M I N D   P A L A C E")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(sage)
                        .padding(.top, 4)
                        .opacity(appearSubtitle ? 1 : 0)
                        .offset(y: appearSubtitle ? 0 : 8)
                        .animation(.easeOut(duration: 0.8).delay(0.55), value: appearSubtitle)

                    // The famous quote
                    Text("“The game is afoot.”")
                        .font(.system(size: 15, design: .serif).italic())
                        .tracking(1.2)
                        .foregroundStyle(muted)
                        .padding(.top, 14)
                        .opacity(appearQuote ? 1 : 0)
                        .offset(y: appearQuote ? 0 : 6)
                        .animation(.easeOut(duration: 0.85).delay(0.75), value: appearQuote)
                }
            }
            .padding(.horizontal, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            enterApp()
        }
        .onAppear {
            appearRing = true
            appearSilhouette = true
            appearTitle = true
            appearSubtitle = true
            appearQuote = true
            pulseGlow = true
        }
    }

    private func enterApp() {
        withAnimation(.easeInOut(duration: 0.65)) {
            onFinished()
        }
    }

    // Architectural geometric rings representing the structure of the Mind Palace
    private var concentricRings: some View {
        ZStack {
            Circle()
                .stroke(gold.opacity(0.12), lineWidth: 1)
                .frame(width: 260, height: 260)

            Circle()
                .stroke(sage.opacity(0.09), style: StrokeStyle(lineWidth: 1, dash: [6, 8]))
                .frame(width: 380, height: 380)

            Circle()
                .stroke(gold.opacity(0.06), lineWidth: 1)
                .frame(width: 520, height: 520)

            Circle()
                .stroke(cream.opacity(0.04), style: StrokeStyle(lineWidth: 1, dash: [3, 12]))
                .frame(width: 680, height: 680)

            // Cardinal tick marks
            ForEach([0, 90, 180, 270], id: \.self) { deg in
                Rectangle()
                    .fill(gold.opacity(0.2))
                    .frame(width: 1, height: 16)
                    .offset(y: -190)
                    .rotationEffect(.degrees(Double(deg)))
            }
        }
    }
}
