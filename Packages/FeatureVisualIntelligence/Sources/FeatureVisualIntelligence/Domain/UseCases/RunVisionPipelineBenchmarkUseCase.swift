import Foundation

public struct RunVisionPipelineBenchmarkUseCase: Sendable {
  private let runner: VisionBenchmarkRunner

  public init(runner: VisionBenchmarkRunner) {
    self.runner = runner
  }

  public func execute(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<
    BenchmarkResult, Error
  > {
    runner.run(configuration: configuration)
  }

  public func executeLive(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<
    LiveAnalysisResult, Error
  > {
    runner.runLive(configuration: configuration)
  }

  public func updateLiveConfiguration(_ configuration: BenchmarkConfiguration) {
    runner.updateLiveConfiguration(configuration)
  }
}
