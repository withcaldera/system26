import SwiftUI

public struct LiquidSurface: ViewModifier {
  var material: Material = .regular
  var opacity: Double = 1.0

  public init(material: Material = .regular, opacity: Double = 1.0) {
    self.material = material
    self.opacity = opacity
  }

  public func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          // Base
          Rectangle()
            .fill(.black.opacity(0.4))

          // Texture
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
              .opacity(0.5)
          }

          // Inner Light
          Rectangle()
            .strokeBorder(
              LinearGradient(
                colors: [.white.opacity(0.2), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 1
            )
            .padding(1)
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .overlay(
        // Border
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .strokeBorder(
            LinearGradient(
              stops: [
                .init(color: .white.opacity(0.6), location: 0.0),
                .init(color: .white.opacity(0.1), location: 0.3),
                .init(color: .white.opacity(0.05), location: 0.7),
                .init(color: .white.opacity(0.4), location: 1.0)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
          )
          .blendMode(.overlay)
      )
      .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
  }
}

extension View {
  public func liquidSurface(material: Material = .regular, opacity: Double = 1.0) -> some View {
    self.modifier(LiquidSurface(material: material, opacity: opacity))
  }

  public func liquidCapsule() -> some View {
    self
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .background(.thinMaterial, in: Capsule())
      .overlay(
        Capsule()
          .strokeBorder(
            LinearGradient(
              colors: [.white.opacity(0.5), .white.opacity(0.1)],
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: 1
          )
      )
  }
}
