import SwiftUI

public struct RunButton: View {
  let isRunning: Bool
  let action: () -> Void

  public init(isRunning: Bool, action: @escaping () -> Void) {
    self.isRunning = isRunning
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        if isRunning {
          Image(systemName: "square.fill")
            .symbolEffect(.pulse, options: .repeating, isActive: true)
        } else {
          Image(systemName: "play.fill")
        }
      }
      .padding(8)
      .background(isRunning ? Color.red.opacity(0.2) : Theme.accentColor.opacity(0.2))
      .clipShape(Circle())
      .overlay(
        Circle()
          .strokeBorder(isRunning ? Color.red : Theme.accentColor, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

#if DEBUG
  #Preview("Run Button") {
    HStack(spacing: 24) {
      RunButton(isRunning: false) {}
      RunButton(isRunning: true) {}
    }
    .padding()
    .preferredColorScheme(.dark)
  }
#endif
