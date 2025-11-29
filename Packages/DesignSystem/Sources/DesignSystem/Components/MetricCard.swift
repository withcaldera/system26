import SwiftUI

public struct MetricCard: View {
  let title: String
  let value: String
  var unit: String?
  var valueColor: Color?
  var tooltip: String?

  @State private var showInfo = false

  public init(
    title: String,
    value: String,
    unit: String? = nil,
    valueColor: Color? = nil,
    tooltip: String? = nil
  ) {
    self.title = title
    self.value = value
    self.unit = unit
    self.valueColor = valueColor
    self.tooltip = tooltip
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 4) {
        Text(title)
          .font(Theme.subheader)
          .foregroundColor(Theme.labelColor.opacity(0.8))
          .tracking(0.5)

        if tooltip != nil {
          Image(systemName: "info.circle.fill")
            .font(.system(size: 10))
            .foregroundColor(Theme.accentColor)
            .opacity(0.6)
        }

        Spacer()
      }

      HStack(alignment: .firstTextBaseline, spacing: 2) {
        Text(value)
          .font(Theme.metricValue)
          .foregroundColor(valueColor ?? .primary)
          .contentTransition(.numericText())
          .minimumScaleFactor(0.8)
          .lineLimit(1)
          .shadow(color: (valueColor ?? .white).opacity(0.3), radius: 8, x: 0, y: 0)

        if let unit = unit {
          Text(unit)
            .font(Theme.subheader)
            .foregroundColor(Theme.accentColor.opacity(0.8))
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .liquidSurface()
    .help(tooltip ?? "")
    .onTapGesture {
      if tooltip != nil {
        showInfo = true
      }
    }
    .popover(isPresented: $showInfo) {
      if let tip = tooltip {
        Text(tip)
          .padding()
          .frame(width: 200)
          .presentationCompactAdaptation(.popover)
      }
    }
  }
}

#if DEBUG
  #Preview("Metric Card") {
    VStack(spacing: 16) {
      MetricCard(
        title: "Throughput",
        value: "42.1",
        unit: "t/s",
        valueColor: .green,
        tooltip: "Tokens per second"
      )

      MetricCard(
        title: "Memory",
        value: "612",
        unit: "MB",
        valueColor: .blue,
        tooltip: "Resident size"
      )
    }
    .padding()
    .preferredColorScheme(.dark)
  }
#endif
