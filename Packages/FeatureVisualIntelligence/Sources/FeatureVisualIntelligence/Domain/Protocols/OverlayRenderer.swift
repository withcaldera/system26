import Foundation
import SwiftUI
import Vision

public protocol OverlayRenderer: Sendable {
  func map(_ observations: [VNObservation], minimumConfidence: Float) -> [OverlayElement]
}
