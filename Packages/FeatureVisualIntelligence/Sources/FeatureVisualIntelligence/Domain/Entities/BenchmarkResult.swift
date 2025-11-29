import Foundation

public struct BenchmarkResult: Sendable, Codable, Identifiable {
  public let id: UUID
  public let timestamp: Date
  public let deviceModel: String
  public let socIdentifier: String
  public let configuration: BenchmarkConfiguration
  public let totalDuration: TimeInterval
  public let totalFrames: Int
  public let sustainedFPS: Double
  public let averagePipelineLatency: TimeInterval
  public let perTaskLatency: [VisionTaskType: TimeInterval]
  public let thermalDegradationScore: Double

  public init(
    deviceModel: String,
    socIdentifier: String,
    configuration: BenchmarkConfiguration,
    totalDuration: TimeInterval,
    totalFrames: Int,
    sustainedFPS: Double,
    averagePipelineLatency: TimeInterval,
    perTaskLatency: [VisionTaskType: TimeInterval],
    thermalDegradationScore: Double,
    id: UUID = UUID(),
    timestamp: Date = Date()
  ) {
    self.id = id
    self.timestamp = timestamp
    self.deviceModel = deviceModel
    self.socIdentifier = socIdentifier
    self.configuration = configuration
    self.totalDuration = totalDuration
    self.totalFrames = totalFrames
    self.sustainedFPS = sustainedFPS
    self.averagePipelineLatency = averagePipelineLatency
    self.perTaskLatency = perTaskLatency
    self.thermalDegradationScore = thermalDegradationScore
  }
}
