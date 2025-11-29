import SwiftUI

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)

    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

#if DEBUG
  #Preview("Liquid Background") {
    LiquidBackground()
      .frame(height: 240)
      .preferredColorScheme(.dark)
  }
#endif

public struct LiquidBackground: View {
  @State private var t: Float = 0.0
  @State private var meshColors: [Color]

  @AppStorage("isReducedMotion")
  private var isReducedMotion = false
  @Environment(\.accessibilityReduceMotion)
  var reduceMotion

  private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
  private let baseStep: Float = 0.025

  private static let palette: [Color] = [
    Color(hex: "0b0b0f"), Color(hex: "141421"),
    Color(hex: "1f2a44"), Color(hex: "2a1b3d"),
    Color(hex: "1a3a3a"), Color(hex: "0f6b6b"),
    Color(hex: "4abe9e"), Color(hex: "3b82f6"),
    Color(hex: "a855f7"), Color(hex: "3dd6d0"),
    Color(hex: "9d174d"), Color(hex: "ff7f50"),
    Color(hex: "312e81"), Color(hex: "134e4a"),
    Color(hex: "2563eb"), Color(hex: "14b8a6")
  ]

  public init() {
    _meshColors = State(initialValue: (0..<16).map { _ in Self.palette.randomElement() ?? .black })
  }

  private var shouldReduceMotion: Bool {
    isReducedMotion || reduceMotion
  }

  public var body: some View {
    let points: [SIMD2<Float>] = [
      .init(0.00, 0.00), .init(0.33, 0.00), .init(0.66, 0.00), .init(1.00, 0.00),
      .init(0.00, 0.33),
      .init(0.33 + sin(t) * 0.15, 0.33 + cos(t) * 0.15),
      .init(0.66 + sin(t + 2.0) * 0.15, 0.33 + cos(t + 1.5) * 0.15),
      .init(1.00, 0.33),
      .init(0.00, 0.66),
      .init(0.33 + cos(t + 1.0) * 0.15, 0.66 + sin(t + 3.0) * 0.15),
      .init(0.66 + cos(t + 4.0) * 0.15, 0.66 + sin(t + 2.5) * 0.15),
      .init(1.00, 0.66),
      .init(0.00, 1.00), .init(0.33, 1.00), .init(0.66, 1.00), .init(1.00, 1.00)
    ]

    ZStack {
      #if !os(visionOS)
        Color.black.ignoresSafeArea()
      #endif

      MeshGradient(
        width: 4,
        height: 4,
        points: points,
        colors: meshColors
      )
      .opacity(0.8)
      .ignoresSafeArea()
      .overlay {
        GeometryReader { proxy in
          Rectangle()
            .fill(.clear)
            .colorEffect(
              ShaderLibrary.bundle(.module).turbulence(
                .float2(proxy.size.width, proxy.size.height),
                .float(42.0)
              )
            )
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
      }
      .onReceive(timer) { _ in
        // (25% of normal step)
        let step: Float = shouldReduceMotion ? baseStep * 0.25 : baseStep
        t += step
      }
    }
    #if os(visionOS)
      .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
    #endif
  }
}
