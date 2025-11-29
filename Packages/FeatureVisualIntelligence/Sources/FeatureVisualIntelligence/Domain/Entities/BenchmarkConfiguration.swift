import Foundation

public struct BenchmarkConfiguration: Sendable, Codable, Hashable {
  public enum Mode: String, Sendable, Codable, CaseIterable {
    case synthetic
    case liveCamera
  }

  public let selectedTasks: Set<VisionTaskType>
  public let iterationCount: Int
  public let forceCPU: Bool
  public let stressMultiplier: Int
  public let mode: Mode
  public let useFrontCamera: Bool
  public let targetFrameRate: Int
  public let enableMirageEffect: Bool
  public let adaptiveThrottling: Bool
  public let minimumConfidence: Float

  public init(
    selectedTasks: Set<VisionTaskType> = [.faceDetection],
    iterationCount: Int = 1200,
    forceCPU: Bool = false,
    stressMultiplier: Int = 1,
    mode: Mode = .synthetic,
    useFrontCamera: Bool = false,
    targetFrameRate: Int = 30,
    enableMirageEffect: Bool = true,
    adaptiveThrottling: Bool = true,
    minimumConfidence: Float = 0.5
  ) {
    self.selectedTasks = selectedTasks
    self.iterationCount = iterationCount
    self.forceCPU = forceCPU
    self.stressMultiplier = stressMultiplier
    self.mode = mode
    self.useFrontCamera = useFrontCamera
    self.targetFrameRate = targetFrameRate
    self.enableMirageEffect = enableMirageEffect
    self.adaptiveThrottling = adaptiveThrottling
    self.minimumConfidence = minimumConfidence
  }
}
