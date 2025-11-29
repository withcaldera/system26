import Foundation

public protocol VisionBenchmarkRunner: Sendable {
  func run(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<BenchmarkResult, Error>
  func runLive(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<
    LiveAnalysisResult, Error
  >
  func updateLiveConfiguration(_ configuration: BenchmarkConfiguration)
}
