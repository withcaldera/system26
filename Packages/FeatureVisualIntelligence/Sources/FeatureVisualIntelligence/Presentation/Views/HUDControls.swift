import Core
import DesignSystem
import SwiftUI

struct HUDMetricsView: View {
  let fps: Double
  let thermalScore: Double
  let isThrottled: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "cpu")
        Text(String(format: "%.1f %@", fps, "FPS"))
          .font(Font.custom("Menlo", size: 22, relativeTo: .title2).monospacedDigit().weight(.bold))
      }

      HStack {
        Image(systemName: "thermometer.medium")
          .foregroundStyle(thermalColor)
        ProgressView(value: min(thermalScore, 100), total: 100)
          .frame(width: 100)
          .tint(thermalColor)
      }

      if isThrottled {
        Text(Localization.string("THROTTLING_DETECTED"))
          .font(.caption.bold())
          .foregroundStyle(.red)
          .padding(4)
          .background(.ultraThinMaterial)
          .cornerRadius(4)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(12)
  }

  private var thermalColor: Color {
    if thermalScore < 50 {
      return .green
    }
    if thermalScore < 80 {
      return .orange
    }
    return .red
  }
}

#if DEBUG
  #Preview("HUD Metrics + Buttons") {
    VStack(spacing: 16) {
      HUDMetricsView(fps: 26.4, thermalScore: 72, isThrottled: true)
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
  }
#endif
