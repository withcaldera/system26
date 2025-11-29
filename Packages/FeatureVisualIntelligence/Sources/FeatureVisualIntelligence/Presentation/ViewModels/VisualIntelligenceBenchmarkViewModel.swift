import Core
import Foundation
import Observation
import SwiftUI

@Observable
public final class VisualIntelligenceBenchmarkViewModel: @unchecked Sendable {
  public enum LiveState: Sendable {
    case idle
    case streaming
    case throttled
  }

  public var configuration: BenchmarkConfiguration

  public var isRunning = false
  public var progress: Double = 0.0
  public var currentResult: BenchmarkResult?
  public var error: Error?

  public var liveState: LiveState = .idle
  public var liveResult: LiveAnalysisResult?
  public var liveOverlays: [OverlayElement] = []
  public var thermalScore: Double = 0.0
  public var currentFPS: Double = 0.0
  public var droppedFrameCount: Int = 0
  public var currentFrameSize: CGSize = .zero
  public var sessionStartTime: Date?
  public var isRestarting = false
  public var lastLiveFrame: CGImage?

  private let useCase: RunVisionPipelineBenchmarkUseCase
  private var benchmarkTask: Task<Void, Never>?

  public init(useCase: RunVisionPipelineBenchmarkUseCase) {
    self.useCase = useCase
    self.configuration = BenchmarkConfiguration()
  }

  // MARK: - Synthetic Actions

  @MainActor
  public func startBenchmark() {
    guard !isRunning else {
      return
    }
    guard configuration.mode == .synthetic else {
      startLiveBenchmark()
      return
    }

    isRunning = true
    progress = 0.0
    currentResult = nil
    error = nil

    benchmarkTask = Task {
      do {
        for try await result in useCase.execute(configuration: configuration) {
          self.currentResult = result

          let totalExpected = Double(configuration.iterationCount)
          let current = Double(result.totalFrames)
          self.progress = min(current / totalExpected, 1.0)
        }
        self.isRunning = false
        self.progress = 1.0
      } catch {
        self.error = error
        self.isRunning = false
      }
    }
  }

  // MARK: - Live Actions

  @MainActor
  public func startLiveBenchmark() {
    guard !isRunning || isRestarting else {
      return
    }

    liveState = .streaming
    isRunning = true
    error = nil
    if sessionStartTime == nil {
      sessionStartTime = Date()
    }

    benchmarkTask = Task {
      do {
        for try await result in useCase.executeLive(configuration: configuration) {
          self.liveResult = result
          self.liveOverlays = result.overlays
          self.thermalScore = result.thermalScore
          self.currentFPS = result.fps
          self.droppedFrameCount = result.droppedFrameCount
          self.currentFrameSize = result.frameSize
          if let frame = result.currentFrame {
            self.lastLiveFrame = frame
          }

          if self.thermalScore > 80 {
            self.liveState = .throttled
          } else {
            self.liveState = .streaming
          }
        }
      } catch {
        self.error = error
        self.stopBenchmark()
      }
    }
  }

  @MainActor
  public func stopBenchmark() {
    benchmarkTask?.cancel()
    benchmarkTask = nil
    isRunning = false
    isRestarting = false
    liveState = .idle
    liveOverlays = []
    currentFPS = 0
    thermalScore = 0
    sessionStartTime = nil
  }

  @MainActor
  public func toggleMode() {
    let target: BenchmarkConfiguration.Mode = configuration.mode == .synthetic ? .liveCamera : .synthetic
    setMode(target)
  }

  @MainActor
  public func setMode(_ mode: BenchmarkConfiguration.Mode) {
    guard mode != configuration.mode else {
      return
    }

    if isRunning { stopBenchmark() }

    switch mode {
    case .liveCamera:
      configuration = BenchmarkConfiguration(
        selectedTasks: configuration.selectedTasks.isEmpty ? [.faceDetection] : configuration.selectedTasks,
        iterationCount: configuration.iterationCount,
        forceCPU: configuration.forceCPU,
        stressMultiplier: configuration.stressMultiplier,
        mode: .liveCamera,
        useFrontCamera: configuration.useFrontCamera,
        targetFrameRate: configuration.targetFrameRate,
        enableMirageEffect: configuration.enableMirageEffect,
        adaptiveThrottling: configuration.adaptiveThrottling,
        minimumConfidence: configuration.minimumConfidence
      )
      startLiveBenchmark()

    case .synthetic:
      setSyntheticMode(preserveTasks: true)
    }
  }

  @MainActor
  public func resetToSyntheticModeIfLive() {
    guard configuration.mode == .liveCamera else {
      return
    }
    stopBenchmark()
    setSyntheticMode(preserveTasks: true)
  }

  @MainActor
  private func setSyntheticMode(preserveTasks: Bool) {
    configuration = BenchmarkConfiguration(
      selectedTasks: preserveTasks ? configuration.selectedTasks : [.faceDetection],
      iterationCount: configuration.iterationCount,
      forceCPU: configuration.forceCPU,
      stressMultiplier: configuration.stressMultiplier,
      mode: .synthetic,
      useFrontCamera: configuration.useFrontCamera,
      targetFrameRate: configuration.targetFrameRate,
      enableMirageEffect: configuration.enableMirageEffect,
      adaptiveThrottling: configuration.adaptiveThrottling,
      minimumConfidence: configuration.minimumConfidence
    )
  }

  @MainActor
  public func toggleTask(_ task: VisionTaskType) {
    var newTasks = configuration.selectedTasks
    if newTasks.contains(task) {
      newTasks.remove(task)
    } else {
      newTasks.insert(task)
    }

    configuration = BenchmarkConfiguration(
      selectedTasks: newTasks,
      iterationCount: configuration.iterationCount,
      forceCPU: configuration.forceCPU,
      stressMultiplier: configuration.stressMultiplier,
      mode: configuration.mode,
      useFrontCamera: configuration.useFrontCamera,
      targetFrameRate: configuration.targetFrameRate,
      enableMirageEffect: configuration.enableMirageEffect,
      adaptiveThrottling: configuration.adaptiveThrottling,
      minimumConfidence: configuration.minimumConfidence
    )

    useCase.updateLiveConfiguration(configuration)
  }

  @MainActor
  public func setMinimumConfidence(_ value: Float) {
    configuration = BenchmarkConfiguration(
      selectedTasks: configuration.selectedTasks,
      iterationCount: configuration.iterationCount,
      forceCPU: configuration.forceCPU,
      stressMultiplier: configuration.stressMultiplier,
      mode: configuration.mode,
      useFrontCamera: configuration.useFrontCamera,
      targetFrameRate: configuration.targetFrameRate,
      enableMirageEffect: configuration.enableMirageEffect,
      adaptiveThrottling: configuration.adaptiveThrottling,
      minimumConfidence: value
    )

    useCase.updateLiveConfiguration(configuration)
  }

  @MainActor
  public func toggleCamera() {
    let newPosition = !configuration.useFrontCamera
    configuration = BenchmarkConfiguration(
      selectedTasks: configuration.selectedTasks,
      iterationCount: configuration.iterationCount,
      forceCPU: configuration.forceCPU,
      stressMultiplier: configuration.stressMultiplier,
      mode: configuration.mode,
      useFrontCamera: newPosition,
      targetFrameRate: configuration.targetFrameRate,
      enableMirageEffect: configuration.enableMirageEffect,
      adaptiveThrottling: configuration.adaptiveThrottling,
      minimumConfidence: configuration.minimumConfidence
    )

    reloadLiveConfiguration()
  }

  @MainActor
  private func reloadLiveConfiguration() {
    guard isRunning && configuration.mode == .liveCamera else {
      return
    }

    isRestarting = true
    stopBenchmark()
    startLiveBenchmark()

    Task {
      try? await Task.sleep(nanoseconds: 500_000_000)
      isRestarting = false
    }
  }
}
