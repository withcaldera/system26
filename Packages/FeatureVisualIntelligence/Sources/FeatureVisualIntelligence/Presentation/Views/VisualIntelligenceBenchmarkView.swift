import Core
import DesignSystem
import SwiftUI

public struct LiquidBackgroundVisibilityPreferenceKey: PreferenceKey {
  public static var defaultValue: Bool { true }

  public static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}

// swiftlint:disable file_length

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct VisualIntelligenceBenchmarkView: View {
  @State var viewModel: VisualIntelligenceBenchmarkViewModel

  public init(viewModel: VisualIntelligenceBenchmarkViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    ZStack {
      if viewModel.configuration.mode == .liveCamera {
        LiveBenchmarkView(viewModel: viewModel)
      } else {
        SyntheticBenchmarkView(viewModel: viewModel)
      }
    }
    .navigationTitle(Localization.string("VISUAL_INTELLIGENCE"))
    .animation(.spring, value: viewModel.configuration.mode)
    .animation(.spring, value: viewModel.isRunning)
    .toolbar {
      ToolbarItem(placement: trailingToolbarPlacement) {
        modeToggleButton
      }

      ToolbarItem(placement: leadingToolbarPlacement) {
        if viewModel.configuration.mode == .synthetic {
          runButton
        } else {
          Button(
            action: { viewModel.toggleCamera() },
            label: {
              Label(
                Localization.string("SWITCH_CAMERA"),
                systemImage: "arrow.triangle.2.circlepath.camera.fill")
            }
          )
        }
      }
    }
  }

  #if os(macOS)
    private var leadingToolbarPlacement: ToolbarItemPlacement { .navigation }
    private var trailingToolbarPlacement: ToolbarItemPlacement { .primaryAction }
  #else
    private var leadingToolbarPlacement: ToolbarItemPlacement { .topBarLeading }
    private var trailingToolbarPlacement: ToolbarItemPlacement { .topBarTrailing }
  #endif

  var runButton: some View {
    Button(
      action: {
        if viewModel.isRunning {
          viewModel.stopBenchmark()
        } else {
          viewModel.startBenchmark()
        }
      },
      label: {
        ZStack {
          if viewModel.isRunning {
            HStack(spacing: 6) {
              ProgressView()
                .controlSize(.small)
              Image(systemName: "square.fill")
                .imageScale(.medium)
                .symbolEffect(.pulse, options: .repeating, isActive: viewModel.isRunning)
            }
          } else {
            Text(Localization.string("START_TEST"))
          }
        }
        .frame(minWidth: 44)
      }
    )
    .controlSize(.extraLarge)
    .disabled(viewModel.configuration.selectedTasks.isEmpty)
    #if os(visionOS)
      .buttonStyle(.plain)
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .glassBackgroundEffect(in: Capsule())
    #else
      .buttonStyle(.glass)
      .clipShape(Capsule())
    #endif
  }

  @ViewBuilder
  var modeToggleButton: some View {
    #if os(visionOS)
      EmptyView()
    #else
      let binding = Binding(
        get: { viewModel.configuration.mode },
        set: { newValue in viewModel.setMode(newValue) }
      )

      Picker(Localization.string("MODE"), selection: binding) {
        Text(Localization.string("SYNTHETIC_TEST")).tag(BenchmarkConfiguration.Mode.synthetic)
        Text(Localization.string("LIVE_CAMERA")).tag(BenchmarkConfiguration.Mode.liveCamera)
      }
      .labelsHidden()
      .frame(alignment: .center)
    #endif
  }
}

// MARK: - Synthetic View

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct SyntheticBenchmarkView: View {
  @Bindable var viewModel: VisualIntelligenceBenchmarkViewModel

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 12) {
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            if let result = viewModel.currentResult {
              MetricCard(
                title: Localization.string("METRIC_THROUGHPUT"),
                value: String(format: "%.1f", result.sustainedFPS),
                unit: Localization.string("UNIT_FRAMES_PER_SECOND"),
                valueColor: .green,
                tooltip: "Frames processed per second during the synthetic run."
              )

              MetricCard(
                title: Localization.string("METRIC_LATENCY"),
                value: String(format: "%.1f", result.averagePipelineLatency * 1000),
                unit: "ms",
                valueColor: .orange,
                tooltip: "Average per-frame pipeline latency (lower is better)."
              )

              MetricCard(
                title: Localization.string("METRIC_TOTAL_TIME"),
                value: String(format: "%.1f", result.totalDuration),
                unit: "s",
                valueColor: .blue,
                tooltip: "Total elapsed time to complete the benchmark run."
              )

              MetricCard(
                title: Localization.string("METRIC_THERMAL_SCORE"),
                value: String(format: "%.0f", result.thermalDegradationScore),
                unit: "/100",
                valueColor: result.thermalDegradationScore > 50 ? .red : .gray,
                tooltip: Localization.string("THERMAL_TOOLTIP")
              )
            } else {
              MetricCard(
                title: Localization.string("METRIC_THROUGHPUT"),
                value: "-",
                unit: Localization.string("UNIT_FRAMES_PER_SECOND"),
                valueColor: .secondary,
                tooltip: "Frames processed per second during the synthetic run."
              )
              MetricCard(
                title: Localization.string("METRIC_LATENCY"),
                value: "-",
                unit: "ms",
                valueColor: .secondary,
                tooltip: "Average per-frame pipeline latency (lower is better)."
              )
              MetricCard(
                title: Localization.string("METRIC_TOTAL_TIME"),
                value: "-",
                unit: "s",
                valueColor: .secondary,
                tooltip: "Total elapsed time to complete the benchmark run."
              )
              MetricCard(
                title: Localization.string("METRIC_THERMAL_SCORE"),
                value: "-",
                unit: "/100",
                valueColor: .secondary,
                tooltip: Localization.string("THERMAL_TOOLTIP")
              )
            }
          }
        }
        .padding()

        if viewModel.isRunning {
          VStack(spacing: 16) {
            ProgressView(value: viewModel.progress)
              .tint(Theme.accentColor)
            Text(Localization.string("ANALYZING_NEURAL_ENGINE"))
              .font(.headline)
              .foregroundStyle(.secondary)
          }
          .padding()
          .liquidSurface()
          .padding(.horizontal)
        }

        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text(Localization.string("WORKLOADS"))
              .font(.caption.weight(.bold))
              .foregroundStyle(.secondary)
            Spacer()
          }

          LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
            ForEach(VisionTaskType.allCases) { task in
              TaskToggle(
                title: task.displayName,
                description: task.description,
                icon: icon(for: task),
                isSelected: viewModel.configuration.selectedTasks.contains(task)
              ) {
                viewModel.toggleTask(task)
              }
              .disabled(viewModel.isRunning)
            }
          }
        }
        .padding()
      }
    }
    .preference(key: LiquidBackgroundVisibilityPreferenceKey.self, value: true)
  }

  func icon(for task: VisionTaskType) -> String {
    switch task {
    case .textRecognition:
      return "text.viewfinder"

    case .objectDetection:
      return "viewfinder"

    case .faceDetection:
      return "face.dashed"

    case .featurePrint:
      return "photo.artframe"

    case .bodyPose:
      return "figure.walk"
    }
  }
}

// MARK: - Live View

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct LiveBenchmarkView: View {
  @Bindable var viewModel: VisualIntelligenceBenchmarkViewModel

  #if os(iOS) || os(visionOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
  #endif

  private var isCompact: Bool {
    #if os(iOS) || os(visionOS)
      horizontalSizeClass == .compact
    #else
      false
    #endif
  }

  var body: some View {
    if viewModel.isRunning {
      ZStack {
        ZStack {
          LiveCameraPreview()
            .ignoresSafeArea()

          if viewModel.isRestarting, let lastFrame = viewModel.lastLiveFrame {
            Image(decorative: lastFrame, scale: 1.0, orientation: .up)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
              .ignoresSafeArea()
          }

          OverlayCanvas(
            elements: viewModel.liveOverlays,
            thermalScore: viewModel.thermalScore,
            startTime: viewModel.sessionStartTime ?? Date(),
            frameSize: viewModel.currentFrameSize
          )
          .ignoresSafeArea()
        }
        .blur(radius: viewModel.isRestarting ? 15 : 0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRestarting)

        VStack {
          Spacer()
          Group {
            VStack(alignment: .trailing, spacing: 12) {
              HUDMetricsView(
                fps: viewModel.currentFPS,
                thermalScore: viewModel.thermalScore,
                isThrottled: viewModel.liveState == .throttled
              )

              LiveSettingsPanel(viewModel: viewModel)
            }
          }
        }
      }
      .transition(.opacity)
      .preference(key: LiquidBackgroundVisibilityPreferenceKey.self, value: false)
    } else {
      VStack(spacing: 24) {
        Image(systemName: "camera.aperture")
          .font(.system(size: 80))
          .foregroundStyle(.white)
          .padding(.bottom, 20)
      }
      .padding()
      .preference(key: LiquidBackgroundVisibilityPreferenceKey.self, value: false)
    }
  }
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct LiveSettingsPanel: View {
  @Bindable var viewModel: VisualIntelligenceBenchmarkViewModel

  @State private var isExpanded = false

  let columns = [GridItem(.adaptive(minimum: 60, maximum: 110), spacing: 8)]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Label(Localization.string("SENSITIVITY"), systemImage: "slider.horizontal.3")
            .font(.caption.bold())
            .foregroundStyle(.white)
          Spacer()
          Text("\(Int(viewModel.configuration.minimumConfidence * 100))%")
            .font(Font.custom("Menlo", size: 12, relativeTo: .caption).monospacedDigit())
            .foregroundStyle(.white.opacity(0.8))
        }

        Slider(
          value: Binding(
            get: { viewModel.configuration.minimumConfidence },
            set: { viewModel.setMinimumConfidence($0) }
          ),
          in: 0.1...1.0,
          step: 0.05
        )
        .tint(.white)
        .controlSize(.mini)
      }

      Divider().background(.white.opacity(0.3))

      DisclosureGroup(isExpanded: $isExpanded) {
        LazyVGrid(columns: columns, spacing: 8) {
          ForEach(VisionTaskType.allCases) { task in
            CompactTaskButton(
              title: task.displayName,
              description: task.description,
              icon: icon(for: task),
              isSelected: viewModel.configuration.selectedTasks.contains(task)
            ) {
              viewModel.toggleTask(task)
            }
            .animation(
              .easeInOut(duration: 0.1), value: viewModel.configuration.selectedTasks.contains(task))
          }
        }
        .padding(.top, 4)
      } label: {
        HStack {
          Label(Localization.string("WORKLOADS"), systemImage: "list.bullet.rectangle")
            .font(.caption.bold())
            .foregroundStyle(.white)
          Spacer()
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .font(.caption.bold())
            .foregroundStyle(.white.opacity(0.7))
        }
        .contentShape(Rectangle())
      }
    }
    .padding(12)
    .background(.regularMaterial)
  }

  func icon(for task: VisionTaskType) -> String {
    switch task {
    case .textRecognition:
      return "text.viewfinder"

    case .objectDetection:
      return "viewfinder"

    case .faceDetection:
      return "face.dashed"

    case .featurePrint:
      return "photo.artframe"

    case .bodyPose:
      return "figure.walk"
    }
  }
}

// MARK: - Components

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct TaskToggle: View {
  let title: String
  let description: String
  let icon: String
  let isSelected: Bool
  let action: () -> Void

  @State private var showInfo = false

  var body: some View {
    Button(
      action: action
    ) {
      VStack(spacing: 12) {
        Image(systemName: icon)
          .font(.title2)
          .foregroundStyle(isSelected ? .white : .secondary)
          .symbolEffect(.bounce, value: isSelected)

        Text(title)
          .font(.caption.weight(.medium))
          .multilineTextAlignment(.center)
          .foregroundStyle(isSelected ? .white : .primary)
      }
      .frame(maxWidth: 174, maxHeight: 174)
      .padding(.vertical, 12)
      .background {
        ZStack {
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(isSelected ? .thickMaterial : .ultraThinMaterial)

          if isSelected {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .fill(Color.purple.opacity(0.3))
          }

          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
              LinearGradient(
                colors: [
                  .white.opacity(isSelected ? 0.6 : 0.3),
                  .white.opacity(isSelected ? 0.2 : 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 1
            )
        }
      }
      .shadow(color: isSelected ? Color.white.opacity(0.1) : .clear, radius: 8, x: 0, y: 4)
      .overlay(alignment: .topTrailing) {
        Button(
          action: { showInfo.toggle() },
          label: {
            Image(systemName: "info.circle")
              .font(.caption2)
              .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
              .padding(8)
          }
        )
        .buttonStyle(.plain)
        .popover(isPresented: $showInfo) {
          Text(description)
            .font(.caption)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .frame(maxWidth: 260, alignment: .leading)
            .presentationCompactAdaptation(.popover)
        }
      }
    }
    .buttonStyle(.plain)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
  }
}

private struct CompactTaskButton: View {
  let title: String
  let description: String
  let icon: String
  let isSelected: Bool
  let action: () -> Void

  @State private var showInfo = false

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.headline)
        Text(title.replacingOccurrences(of: " ", with: "\n"))
          .font(.system(size: 8.8, weight: .medium))
          .multilineTextAlignment(.center)
          .lineSpacing(1)
          .lineLimit(3)
          .minimumScaleFactor(0.75)
      }
      .frame(maxWidth: .infinity, minHeight: 60)
      .aspectRatio(1.0, contentMode: .fit)
      .padding(3)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(isSelected ? Theme.accentColor.opacity(0.35) : Color.black.opacity(0.2))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(isSelected ? Theme.accentColor : Color.white.opacity(0.1), lineWidth: 1)
      )
      .overlay(alignment: .topTrailing) {
        Button(
          action: { showInfo.toggle() },
          label: {
            Image(systemName: "info.circle")
              .font(.caption2)
              .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
              .padding(6)
          }
        )
        .buttonStyle(.plain)
        .popover(isPresented: $showInfo) {
          Text(description)
            .font(.caption)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .frame(maxWidth: 240, alignment: .leading)
            .presentationCompactAdaptation(.popover)
        }
      }
    }
    .buttonStyle(.plain)
    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
  }
}

#if DEBUG
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("Synthetic Benchmark") {
    NavigationStack {
      VisualIntelligenceBenchmarkView(viewModel: .previewSynthetic())
        .preferredColorScheme(.dark)
    }
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("Live Benchmark (Idle)") {
    NavigationStack {
      VisualIntelligenceBenchmarkView(viewModel: .previewLive())
        .preferredColorScheme(.dark)
    }
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("Task Toggle") {
    TaskToggle(
      title: "Object Detection",
      description: "Detects common household items in the frame.",
      icon: "viewfinder",
      isSelected: true
    ) {}
    .padding()
    .preferredColorScheme(.dark)
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("HUD Metrics") {
    HUDMetricsView(fps: 26.4, thermalScore: 42, isThrottled: false)
      .padding()
      .background(.black)
      .preferredColorScheme(.dark)
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("Live Settings Panel") {
    LiveSettingsPanel(viewModel: .previewLive())
      .frame(width: 300)
      .preferredColorScheme(.dark)
  }
#endif
