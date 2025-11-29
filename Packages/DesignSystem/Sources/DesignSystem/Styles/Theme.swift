import SwiftUI

public enum Theme {
  private static let monoName = "Menlo"

  public static let background = Color(red: 9 / 255, green: 9 / 255, blue: 11 / 255)  // Zinc-950
  public static let cardBackground = Material.ultraThin
  public static let borderColor = Color.white.opacity(0.15)
  public static let accentColor = Color(red: 139 / 255, green: 92 / 255, blue: 246 / 255)  // Violet-500
  public static let secondaryColor = Color(red: 6 / 255, green: 182 / 255, blue: 212 / 255)  // Cyan-500
  public static let successColor = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)  // Emerald-500
  public static let terminalText = Color(red: 228 / 255, green: 228 / 255, blue: 231 / 255)  // Zinc-200
  public static let labelColor = Color.white.opacity(0.5)

  // MARK: - Typography

  public static let appTitle = Font.custom(monoName, size: 17, relativeTo: .headline).weight(.bold)

  public static let sectionHeader = Font.custom(monoName, size: 15, relativeTo: .subheadline).weight(.bold)

  public static let subheader = Font.custom(monoName, size: 13, relativeTo: .footnote).weight(.medium)

  public static let body = Font.custom(monoName, size: 17, relativeTo: .body)

  public static let metricValue = Font.system(.largeTitle, design: .rounded).weight(.medium)

  public static let monoFont = Font.custom(monoName, size: 17, relativeTo: .body)
  public static let headingFont = Font.custom(monoName, size: 22, relativeTo: .title2).weight(.bold)
  public static let displayFont = Font.custom(monoName, size: 34, relativeTo: .largeTitle).weight(.black)
}
