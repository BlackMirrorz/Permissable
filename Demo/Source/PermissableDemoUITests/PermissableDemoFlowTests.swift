//
//  PermissableDemoFlowTests.swift
//  PermissableDemoUITests
//
//  Created by Josh Robbins on 2/19/25.
//

import XCTest

final class PermissableDemoFlowTests: XCTestCase {

  enum Service: String, CaseIterable {
    case camera
    case microphone
    case photoLibrary
    case notifications

    func buttonIndex(agreesToPermissions: Bool) -> Int {
      switch agreesToPermissions {
      case true:
        return 1
      case false:
        switch self {
        case .camera:
          return 0
        case .microphone:
          return 0
        case .photoLibrary:
          return 2
        case .notifications:
          return 0
        }
      }
    }
  }

  private let icons = [
    "camera.circle",
    "microphone.circle",
    "photo.circle",
    "bell.circle"
  ]

  private let app = XCUIApplication()

  // MARK: - LifeCycle

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

  override func tearDown() {
    super.tearDown()
    app.terminate()
  }

  // MARK: - Initial State

  func testInitialStatesWithNoPermissions() {
    app.uninstall()
    launchAndResetPermissions()
    validateIcons()
    validateAllInitialStatusTexts()
  }

  // MARK: - Permissions

  func launchAndResetPermissions() {
    resetPermissions()
    app.launch()
  }

  func testPermissionsSuccess() {
    app.uninstall()
    launchAndResetPermissions()
    validateServiceStatusForPermissions(.camera, agrees: true, resets: false)
    validateServiceStatusForPermissions(.microphone, agrees: true, resets: false)
    validateServiceStatusForPermissions(.photoLibrary, agrees: true, resets: false)
    validateServiceStatusForPermissions(.notifications, agrees: true, resets: false)
  }

  func testPermissionsFailure() {
    app.uninstall()
    launchAndResetPermissions()
    validateServiceStatusForPermissions(.camera, agrees: true, resets: false)
    validateServiceStatusForPermissions(.microphone, agrees: true, resets: false)
    validateServiceStatusForPermissions(.photoLibrary, agrees: true, resets: false)
    validateServiceStatusForPermissions(.notifications, agrees: true, resets: false)
  }

  // MARK: - Persistance

  func testPersistedState() {
    app.uninstall()
    launchAndResetPermissions()
    validateServiceStatusForPermissions(.camera, agrees: true, resets: false)
    validateServiceStatusForPermissions(.microphone, agrees: true, resets: false)
    validateServiceStatusForPermissions(.photoLibrary, agrees: true, resets: false)
    validateServiceStatusForPermissions(.notifications, agrees: true, resets: false)
    app.terminate()
    app.launch()

    for item in Service.allCases {
      let expectation = item.rawValue + "-Authorized"
      validateStatusText(expectation)
    }
  }
}

// MARK: - Validators

extension PermissableDemoFlowTests {

  private func validateAllInitialStatusTexts() {
    for item in Service.allCases {
      let expectation = item.rawValue + "-Not Determined"
      validateStatusText(expectation)
    }
  }

  private func validateIcons() {
    for icon in icons {
      assertElementExists(
        app.images[icon],
        failureMessage: "Icon \(icon) should be visible."
      )
    }
  }

  private func validateStatusText(_ expectation: String) {
    assertElementExists(
      app.staticTexts[expectation],
      failureMessage: "Status text should be not determined fall all services"
    )
  }

  private func validateServiceStatusForPermissions(_ service: Service, agrees: Bool, resets: Bool = true) {

    let prefix = service.rawValue

    let button = app.buttons["\(prefix)-Ask"]
    validatePermission(
      button: button,
      buttonIndex: service.buttonIndex(agreesToPermissions: agrees),
      expectationID: UUID().uuidString
    )

    switch agrees {
    case true:
      assertElementExists(
        app.staticTexts["\(prefix)-Authorized"],
        failureMessage: "\(prefix) State should be Authorized"
      )
    case false:
      assertElementExists(
        app.staticTexts["\(prefix)-Denied"],
        failureMessage: "\(prefix) State should be Authorized"
      )
      assertElementExists(
        app.buttons["\(prefix)-Open Settings"],
        failureMessage: "\(prefix) Should show the open settings button"
      )
    }

    if resets {
      resetPermissions()
    }
  }

  private func validatePermission(button: XCUIElement, buttonIndex: Int, expectationID: String) {
    let expectation = expectation(description: "Waiting for dialogue \(expectationID)")

    let monitor = addUIInterruptionMonitor(withDescription: "Authorization Dialog") { alert in
      let actionButton = alert.buttons.element(boundBy: buttonIndex)
      if actionButton.exists {
        actionButton.tap()
        expectation.fulfill()
        return true
      }
      return false
    }

    if button.waitForExistence(timeout: 5) {
      button.tap()
    } else {
      XCTFail("Button did not appear in time")
    }

    sleep(2)

    app.swipeUp()

    wait(for: [expectation], timeout: 5)

    removeUIInterruptionMonitor(monitor)
  }
}

// MARK: - Helpers

extension PermissableDemoFlowTests {

  private func assertElementExists(_ element: XCUIElement, failureMessage _: String) {
    XCTAssertTrue(
      element.waitForExistence(timeout: 3),
      "Status text should be not determined fall all services"
    )
  }

  private func resetPermissions() {
    app.resetAuthorizationStatus(for: .microphone)
    app.resetAuthorizationStatus(for: .photos)
    app.resetAuthorizationStatus(for: .camera)
    sleep(2)
  }
}

// MARK: - App Removal

/**
 Apple currently dont allow us to reset PushNotification Authorization Status so we need
 to delete the app each time to enusre that the logic is correct.

 Acknowledgement: https://tinyurl.com/2b5an7zn
 */

extension XCUIApplication {

  fileprivate func uninstall(name: String? = nil) {
    terminate()

    let timeout = TimeInterval(5)
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    let appName: String

    if let name = name {
      appName = name
    } else {
      let uiTestRunnerName = Bundle.main.infoDictionary?["CFBundleName"] as! String
      appName = uiTestRunnerName.replacingOccurrences(of: "UITests-Runner", with: "")
    }

    let appIcon = springboard.icons[appName].firstMatch

    if appIcon.waitForExistence(timeout: timeout) {
      appIcon.press(forDuration: 2)
    } else {
      return
    }

    let removeAppButton = springboard.buttons["Remove App"]

    if removeAppButton.waitForExistence(timeout: timeout) {
      removeAppButton.tap()
    } else {
      return
    }

    let deleteAppButton = springboard.alerts.buttons["Delete App"]

    if deleteAppButton.waitForExistence(timeout: timeout) {
      deleteAppButton.tap()
    } else {
      return
    }

    let finalDeleteButton = springboard.alerts.buttons["Delete"]

    if finalDeleteButton.waitForExistence(timeout: timeout) {
      finalDeleteButton.tap()
    } else {
      return
    }
  }
}
