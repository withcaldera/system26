import Foundation
import SwiftUI
import Vision

public struct CoordinateTransformerUseCase: Sendable {
  public init() {}

  public func transform(rect: CGRect) -> CGRect {
    let flippedY = 1.0 - rect.maxY

    return CGRect(x: rect.minX, y: flippedY, width: rect.width, height: rect.height)
  }

  public func transform(point: CGPoint) -> CGPoint {
    let y = 1.0 - point.y
    return CGPoint(x: point.x, y: y)
  }
}
