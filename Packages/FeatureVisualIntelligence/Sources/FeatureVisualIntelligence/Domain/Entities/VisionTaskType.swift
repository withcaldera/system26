import Core
import Foundation

public enum VisionTaskType: String, CaseIterable, Sendable, Codable, Identifiable {
  case textRecognition
  case objectDetection
  case faceDetection
  case featurePrint
  case bodyPose

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .textRecognition:
      return Localization.string("TASK_TEXT_RECOGNITION")

    case .objectDetection:
      return Localization.string("TASK_OBJECT_DETECTION")

    case .faceDetection:
      return Localization.string("TASK_FACE_DETECTION")

    case .featurePrint:
      return Localization.string("TASK_FEATURE_PRINT")

    case .bodyPose:
      return Localization.string("TASK_BODY_POSE")
    }
  }

  public var description: String {
    switch self {
    case .textRecognition:
      return Localization.string("TASK_TEXT_RECOGNITION_DESC")

    case .objectDetection:
      return Localization.string("TASK_OBJECT_DETECTION_DESC")

    case .faceDetection:
      return Localization.string("TASK_FACE_DETECTION_DESC")

    case .featurePrint:
      return Localization.string("TASK_FEATURE_PRINT_DESC")

    case .bodyPose:
      return Localization.string("TASK_BODY_POSE_DESC")
    }
  }
}
