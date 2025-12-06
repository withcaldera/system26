import Core
import DesignSystem
import SwiftUI

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct LLMDashboardView: View {
  let viewModel: LLMDashboardViewModel

  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  var columns: [GridItem] {
    guard horizontalSizeClass == .compact else {
      return Array(repeating: GridItem(.flexible(minimum: 200), spacing: 12), count: 3)
    }
    return [GridItem(.flexible())]
  }

  public init(viewModel: LLMDashboardViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    @Bindable var vm = viewModel

    BenchmarkScreenContainer {
      LazyVGrid(columns: columns, spacing: 16) {
        MetricCard(
          title: Localization.string("TOKENS_PER_SECOND"),
          value: String(format: "%.2f", vm.state.tokensPerSecond),
          unit: "t/s",
          valueColor: Theme.accentColor,
          tooltip: Localization.string("TOKENS_PER_SECOND_TOOLTIP")
        )

        MetricCard(
          title: Localization.string("TOKENS"),
          value: String(vm.state.tokenCount),
          unit: Localization.string("UNIT_COUNT"),
          valueColor: .purple,
          tooltip: Localization.string("TOKEN_ESTIMATION_EXPLANATION")
        )

        MetricCard(
          title: Localization.string("TIME_TO_FIRST_TOKEN"),
          value: String(format: "%.0f", vm.state.timeToFirstToken),
          unit: "ms",
          valueColor: Theme.secondaryColor,
          tooltip: Localization.string("TIME_TO_FIRST_TOKEN_TOOLTIP")
        )

        MetricCard(
          title: Localization.string("MEMORY_USAGE"),
          value: vm.state.memoryUsage,
          unit: Localization.string("UNIT_MEGA_BYTES"),
          valueColor: .blue,
          tooltip: Localization.string("MEMORY_USAGE_TOOLTIP")
        )
      }

      VStack(alignment: .leading, spacing: 12) {
        Text(Localization.string("CONFIGURATION"))
          .font(Theme.sectionHeader)
          .tracking(1.0)
          .foregroundStyle(.secondary)
          .padding(.leading, 8)

        VStack(alignment: .leading, spacing: 16) {
          if horizontalSizeClass == .compact {
            VStack(alignment: .leading, spacing: 4) {
              Text(Localization.string("USE_CASE"))
                .font(Theme.subheader)
                .foregroundStyle(.secondary)

              Picker(Localization.string("USE_CASE"), selection: $vm.selectedModel) {
                ForEach(ModelType.allCases, id: \.self) { model in
                  Text(model.localizedName)
                    .tag(model)
                }
              }
              .pickerStyle(.menu)
              .labelsHidden()
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          } else {
            LabeledContent {
              Picker(Localization.string("USE_CASE"), selection: $vm.selectedModel) {
                ForEach(ModelType.allCases, id: \.self) { model in
                  Text(model.localizedName)
                    .tag(model)
                }
              }
              .pickerStyle(.menu)
              .labelsHidden()
            } label: {
              Text(Localization.string("USE_CASE"))
                .font(Theme.subheader)
                .foregroundStyle(.secondary)
            }
          }

          VStack(alignment: .leading, spacing: 6) {
            Text(Localization.string("USE_CASE_GUIDANCE"))
              .font(.footnote)
              .foregroundStyle(.secondary)

            Text("• \(Localization.string("USE_CASE_GENERAL_HINT"))")
              .font(.caption)
              .foregroundStyle(.secondary)

            Text("• \(Localization.string("USE_CASE_TAGGING_HINT"))")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .padding(.top, 4)

          Divider().overlay(.white.opacity(0.1))

          VStack(alignment: .leading, spacing: 8) {
            Text(Localization.string("SYSTEM_PROMPT"))
              .font(Theme.subheader)
              .foregroundStyle(.secondary)

            TextEditor(text: $vm.systemPrompt)
              .font(Theme.body)
              .scrollContentBackground(.hidden)
              .frame(height: 80)
              .padding(8)
              .background(vm.isSystemPromptEnabled ? .black.opacity(0.2) : .black.opacity(0.05))
              .cornerRadius(8)
              .disabled(!vm.isSystemPromptEnabled)
              .foregroundStyle(vm.isSystemPromptEnabled ? .primary : .secondary)
          }

          Divider().overlay(.white.opacity(0.1))

          VStack(alignment: .leading, spacing: 8) {
            Text(Localization.string("USER_PROMPT"))
              .font(Theme.subheader)
              .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: 12) {
              TextEditor(text: $vm.prompt)
                .font(Theme.body)
                .scrollContentBackground(.hidden)
                .frame(height: 80)
                .padding(8)
                .background(.black.opacity(0.2))
                .cornerRadius(8)

              Button(
                action: {
                  Task {
                    if vm.state.isGenerating {
                      vm.abortBenchmark()
                    } else {
                      vm.runBenchmark()
                    }
                  }
                },
                label: {
                  ZStack {
                    if vm.state.isGenerating {
                      Image(systemName: "square.fill")
                        .imageScale(.medium)
                        .symbolEffect(.pulse, options: .repeating, isActive: vm.state.isGenerating)
                    } else {
                      Image(systemName: "play.fill")
                    }
                  }
                  .frame(width: 44, height: 44)
                }
              )
              .buttonStyle(.plain)
              .background(vm.state.isGenerating ? Color.red.opacity(0.2) : Theme.accentColor.opacity(0.2))
              .clipShape(Circle())
              .overlay(
                Circle()
                  .strokeBorder(vm.state.isGenerating ? Color.red : Theme.accentColor, lineWidth: 1)
              )
            }
          }
        }
        .padding(20)
        .liquidSurface()
      }

      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text(Localization.string("OUTPUT"))
            .font(Theme.sectionHeader)
            .tracking(1.0)
            .foregroundStyle(.secondary)
          Spacer()
        }
        .padding(.leading, 8)

        ScrollView {
          Text(
            vm.state.responseText.isEmpty
              ? Localization.string("WAITING_FOR_EXECUTION") : vm.state.responseText
          )
          .font(Theme.body)
          .foregroundStyle(.primary)
          .opacity(vm.state.responseText.isEmpty ? 0.5 : 1.0)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
        }
        .frame(height: 200)
        .liquidSurface()
      }
    }
    .navigationTitle(Localization.string("LANGUAGE_MODELS"))
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(
          action: {
            Task {
              if vm.state.isGenerating {
                vm.abortBenchmark()
              } else {
                vm.runBenchmark()
              }
            }
          },
          label: {
            ZStack {
              if vm.state.isGenerating {
                HStack(spacing: 6) {
                  ProgressView()
                    .controlSize(.small)
                  Image(systemName: "square.fill")
                    .imageScale(.medium)
                    .symbolEffect(.pulse, options: .repeating, isActive: vm.state.isGenerating)
                }
              } else {
                Text(Localization.string("START_TEST"))
                  .font(.body)
                  .frame(minWidth: 44)
              }
            }
            .frame(minWidth: 44)
          }
        )
        .controlSize(.extraLarge)
        .accessibilityIdentifier("RunStopButton")
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
    }
    .liquidErrorPresentation(
      error: Binding(
        get: {
          guard let message = vm.errorMessage else {
            return nil
          }

          return LiquidError(
            title: Localization.string("ERROR"),
            message: message,
            suggestion: nil
          )
        },
        set: { newValue in
          if newValue == nil {
            vm.errorMessage = nil
          }
        }
      ))
  }
}

struct BenchmarkScreenContainer<Content: View>: View {
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

#if DEBUG
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("LLM Dashboard") {
    LLMDashboardView(viewModel: .preview)
      .preferredColorScheme(.dark)
  }
#endif
