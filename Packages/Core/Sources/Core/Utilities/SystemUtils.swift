import Foundation

#if canImport(UIKit)
  import UIKit
#endif

@MainActor
public func getSystemID() -> String {
  #if canImport(UIKit)
    let device = UIDevice.current
    #if os(visionOS)
      return "SYSTEM_ID: VISIONOS-\(device.systemVersion)"
    #else
      return "SYSTEM_ID: IOS-\(device.systemVersion)"
    #endif
  #elseif os(macOS)
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    return "SYSTEM_ID: MACOS-\(osVersion.majorVersion).\(osVersion.minorVersion)"
  #else
    return "SYSTEM_ID: UNKNOWN"
  #endif
}
