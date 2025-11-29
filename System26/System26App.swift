import Core
import DesignSystem
import FeatureImageGen
import FeatureLLM
import FeatureVisualIntelligence
import SwiftUI

@main
struct System26App: App {
  @State private var llmViewModel: LLMDashboardViewModel
  @State private var imageGenViewModel: ImageGenViewModel
  @State private var visualIntelligenceViewModel: VisualIntelligenceBenchmarkViewModel
  @State private var isLiquidBackgroundVisible = true

  init() {
    let llmService = LLMService()
    let runLLMUseCase = RunLLMBenchmarkUseCase(service: llmService)
    _llmViewModel = State(initialValue: LLMDashboardViewModel(runBenchmarkUseCase: runLLMUseCase))

    let imageGenService = ImageGenService()
    _imageGenViewModel = State(initialValue: ImageGenViewModel(service: imageGenService))

    let visionRepo = VisionBenchmarkRepository()
    let visionUseCase = RunVisionPipelineBenchmarkUseCase(runner: visionRepo)
    _visualIntelligenceViewModel = State(initialValue: VisualIntelligenceBenchmarkViewModel(useCase: visionUseCase))
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        System26AppView(
          llmViewModel: llmViewModel,
          imageGenViewModel: imageGenViewModel,
          visualIntelligenceViewModel: visualIntelligenceViewModel,
          isLiquidBackgroundVisible: $isLiquidBackgroundVisible
        )

        if isLiquidBackgroundVisible {
          LiquidBackground()
            .allowsHitTesting(false)
            .blendMode(.screen)
            .opacity(0.3)
            .transition(.opacity)
        }
      }
    }
    #if os(visionOS)
      .windowStyle(.plain)
    #elseif os(macOS)
      .windowStyle(.hiddenTitleBar)
    #endif
  }
}
