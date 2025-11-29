import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTakeScreenshots() throws {
        // Wait for app to fully load
        sleep(2)

        // Take screenshot of initial state (sidebar/home)
        takeScreenshot(named: "01_Home")

        // Navigate to Language Model screen using accessibility identifier
        let sidebarLLM = app.buttons["sidebar_llm"].firstMatch
        if sidebarLLM.waitForExistence(timeout: 5) {
            sidebarLLM.tap()
        }

        // Wait for navigation animation
        sleep(1)

        // Take screenshot of Language Model screen
        takeScreenshot(named: "02_LanguageModel")

        // On iPhone (compact width), we need to go back to sidebar first
        // Try to find and tap the back button if sidebar isn't visible
        let sidebarAbout = app.buttons["sidebar_about"].firstMatch
        if !sidebarAbout.exists {
            // Look for back button in navigation bar
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.waitForExistence(timeout: 2) {
                backButton.tap()
                sleep(1)
            }
        }

        // Navigate to About screen from sidebar
        if sidebarAbout.waitForExistence(timeout: 5) {
            sidebarAbout.tap()
        }
        sleep(1)

        // Take screenshot of About screen
        takeScreenshot(named: "03_About")
    }

    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
