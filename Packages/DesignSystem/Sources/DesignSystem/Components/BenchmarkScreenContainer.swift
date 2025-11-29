import SwiftUI

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct BenchmarkScreenContainer<Content: View>: View {
  let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        content
      }
      .padding(.horizontal)
      .padding(.vertical, 20)
    }
  }
}
