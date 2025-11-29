import Core
import Foundation
import SwiftUI
import Vision

public struct LiveOverlayRenderer: OverlayRenderer {
  private let coordinateTransformer: CoordinateTransformerUseCase

  public init(coordinateTransformer: CoordinateTransformerUseCase = CoordinateTransformerUseCase()) {
    self.coordinateTransformer = coordinateTransformer
  }

  public func map(_ observations: [VNObservation], minimumConfidence: Float) -> [OverlayElement] {
    var elements: [OverlayElement] = []

    for observation in observations {
      if let textObs = observation as? VNRecognizedTextObservation {
        guard let candidate = textObs.topCandidates(1).first,
          candidate.confidence >= minimumConfidence
        else { continue }

        let rect = coordinateTransformer.transform(rect: textObs.boundingBox)

        elements.append(
          .textBubble(
            id: textObs.uuid,
            rect: rect,
            text: candidate.string
          ))
      }

      if let rectObs = observation as? VNRectangleObservation {
        if rectObs.confidence >= minimumConfidence {
          let rect = coordinateTransformer.transform(rect: rectObs.boundingBox)

          elements.append(
            .boundingBox(
              id: rectObs.uuid,
              rect: rect,
              label: String(
                format: Localization.string("OVERLAY_OBJECT_CONFIDENCE"),
                Int(rectObs.confidence * 100)
              ),
              color: .cyan
            ))
        }
      }

      if let faceObs = observation as? VNFaceObservation {
        if faceObs.confidence >= minimumConfidence {
          let rect = coordinateTransformer.transform(rect: faceObs.boundingBox)

          elements.append(
            .boundingBox(
              id: faceObs.uuid,
              rect: rect,
              label: String(
                format: Localization.string("OVERLAY_FACE_CONFIDENCE"),
                Int(faceObs.confidence * 100)
              ),
              color: .green
            ))
        }
      }

      if let bodyObs = observation as? VNHumanBodyPoseObservation {
        guard let recognizedPoints = try? bodyObs.recognizedPoints(.all) else { continue }

        var joints: [CGPoint] = []
        for (_, point) in recognizedPoints where point.confidence >= minimumConfidence {
          let normalizedPoint = CGPoint(x: point.x, y: point.y)
          let transformed = coordinateTransformer.transform(point: normalizedPoint)
          joints.append(transformed)
        }

        if !joints.isEmpty {
          elements.append(
            .skeleton(
              id: bodyObs.uuid,
              joints: joints,
              connections: []
            ))
        }
      }
    }

    return elements
  }
}
