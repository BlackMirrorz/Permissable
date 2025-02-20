//
//  PermissionsCllientTests.swift
//  Permissable
//
//  Copyright © 2025 Josh Robbins
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
@testable import Permissable
import XCTest

final class PermissionsClientTests: XCTestCase {

  var client: PermissionsClient!
  var cameraValidator: StubPermissionsValidator!
  var microphoneValidator: StubPermissionsValidator!
  var photoLibraryValidator: StubPermissionsValidator!
  var notificationsValidator: StubPermissionsValidator!
  var notificationCenter: NotificationCenter!
  var cancellables: Set<AnyCancellable>!

  // MARK: - LifeCycle

  override func setUp() {
    super.setUp()
    cancellables = []

    notificationCenter = NotificationCenter()

    cameraValidator = StubPermissionsValidator(status: .notDetermined)
    microphoneValidator = StubPermissionsValidator(status: .notDetermined)
    photoLibraryValidator = StubPermissionsValidator(status: .notDetermined)
    notificationsValidator = StubPermissionsValidator(status: .notDetermined)

    let providers: [PermissionsService: any PermissionsValidatorProtocol] = [
      .camera: cameraValidator,
      .microphone: microphoneValidator,
      .photoLibrary: photoLibraryValidator,
      .notifications: notificationsValidator
    ]

    client = PermissionsClient(providers: providers, notificationCenter: notificationCenter)
  }

  override func tearDown() {
    client = nil
    cameraValidator = nil
    microphoneValidator = nil
    photoLibraryValidator = nil
    notificationsValidator = nil
    notificationCenter = nil
    cancellables = nil
    super.tearDown()
  }

  // MARK: - Tests

  func testInitialPermissionStatuses() {
    XCTAssertEqual(
      client.permissionStatuses[.camera],
      .notDetermined,
      "Expected camera status to be .notDetermined initially."
    )
    XCTAssertEqual(
      client.permissionStatuses[.microphone],
      .notDetermined,
      "Expected microphone status to be .notDetermined initially."
    )
    XCTAssertEqual(
      client.permissionStatuses[.photoLibrary],
      .notDetermined,
      "Expected photoLibrary status to be .notDetermined initially."
    )
    XCTAssertEqual(
      client.permissionStatuses[.notifications],
      .notDetermined,
      "Expected notifications status to be .notDetermined initially."
    )
  }

  func testPermissionStatusResolver() async {
    cameraValidator.status = .authorized
    await client.checkCurrentStatuses()

    XCTAssertTrue(
      client.permissionStatusResolver(.camera),
      "Expected resolver to return true for authorized camera."
    )
    XCTAssertFalse(
      client.permissionStatusResolver(.microphone),
      "Expected resolver to return false for microphone (not authorized)."
    )
  }

  func testRequestAuthorizationUpdatesStatus() async throws {
    XCTAssertFalse(
      client.permissionStatusResolver(.camera),
      "Camera should not be authorized initially."
    )

    try await client.requestAuthorization(for: .camera)

    XCTAssertEqual(
      client.permissionStatuses[.camera],
      .authorized,
      "Expected camera status to be updated to .authorized after request."
    )
    XCTAssertTrue(
      client.permissionStatusResolver(.camera),
      "Expected resolver to return true for camera after request."
    )
  }

  func testHasAskedForPermission() async throws {
    XCTAssertFalse(
      client.hasAskedForPermission(for: .photoLibrary),
      "Expected photoLibrary not to have been asked initially."
    )

    try await client.requestAuthorization(for: .photoLibrary)

    XCTAssertTrue(
      client.hasAskedForPermission(for: .photoLibrary),
      "Expected photoLibrary to be marked as asked after request."
    )
  }

  func testIsPermissionGrantedHelper() async {
    notificationsValidator.status = .authorized
    await client.checkCurrentStatuses()

    XCTAssertTrue(
      client.isPermissionGranted(for: .notifications),
      "Expected notifications to be granted when status is authorized."
    )

    notificationsValidator.status = .denied
    await client.checkCurrentStatuses()

    XCTAssertFalse(
      client.isPermissionGranted(for: .notifications),
      "Expected notifications not to be granted when status is denied."
    )
  }

  func testRecommendedActionAuthorized() async {
    notificationsValidator.status = .authorized

    let actualResult = await client.recommendedAction(for: .notifications)
    XCTAssertEqual(actualResult, .none, "Expected recommended action to be .none when permission is authorized.")
  }

  func testRecommendedActionOpenSettings() async {
    cameraValidator.status = .denied
    cameraValidator.hasAsked = true

    let actualResult = await client.recommendedAction(for: .camera)
    XCTAssertEqual(
      actualResult,
      .openSettings,
      "Expected recommended action to be .openSettings when permission has been asked and not granted."
    )
  }

  func testRecommendedActionRequest() async {
    photoLibraryValidator.status = .notDetermined

    let actualResult = await client.recommendedAction(for: .photoLibrary)
    XCTAssertEqual(actualResult, .request, "Expected recommended action to be .request when permission hasn't been asked yet.")
  }

  func testObserveApplicationStateUpdatesStatus() async throws {
    try await Task.sleep(nanoseconds: 200_000_000)
    XCTAssertEqual(
      client.permissionStatuses[.camera],
      .notDetermined,
      "Expected initial camera status to be .notDetermined."
    )

    XCTAssertEqual(
      client.permissionStatuses[.microphone],
      .notDetermined,
      "Expected initial microphone status to be .notDetermined."
    )

    XCTAssertEqual(
      client.permissionStatuses[.photoLibrary],
      .notDetermined,
      "Expected initial photoLibrary status to be .notDetermined."
    )

    XCTAssertEqual(
      client.permissionStatuses[.notifications],
      .notDetermined,
      "Expected initial notifications status to be .notDetermined."
    )

    cameraValidator.status = .authorized
    microphoneValidator.status = .authorized
    photoLibraryValidator.status = .notDetermined
    notificationsValidator.status = .denied

    notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

    try await Task.sleep(nanoseconds: 200_000_000) // 200ms

    XCTAssertEqual(
      client.permissionStatuses[.camera],
      .authorized,
      "Expected camera status to be updated to .authorized after didBecomeActive notification."
    )

    XCTAssertEqual(
      client.permissionStatuses[.microphone],
      .authorized,
      "Expected microphone status to be updated to .authorized after didBecomeActive notification."
    )

    XCTAssertEqual(
      client.permissionStatuses[.photoLibrary],
      .notDetermined,
      "Expected photoLibrary status to remain .notDetermined after didBecomeActive notification."
    )
    XCTAssertEqual(
      client.permissionStatuses[.notifications],
      .denied,
      "Expected notifications status to be updated to .denied after didBecomeActive notification."
    )
  }

  func testReigesterProviders() async {
    let breakService = PermissionsService(identifier: "break", description: "BreakTime")
    let breakValidator = StubPermissionsValidator(status: .notDetermined)

    XCTAssertNil(
      client.permissionStatuses[breakService],
      "Expected break service not to exist before registering new providers."
    )

    let newProviders: [PermissionsService: any PermissionsValidatorProtocol] = [
      breakService: breakValidator
    ]
    client.registerProviders(newProviders)

    XCTAssertEqual(
      client.permissionStatuses[breakService],
      .notDetermined,
      "Expected break service to be initialized to .notDetermined after registration."
    )

    breakValidator.status = .authorized

    await client.checkCurrentStatuses()

    XCTAssertEqual(
      client.permissionStatuses[breakService],
      .authorized,
      "Expected break service to be updated to .authorized after re-checking statuses."
    )
  }
}

// MARK: - Stub

final class StubPermissionsValidator: PermissionsValidatorProtocol {

  var status: PermissionsRequestResult
  var hasAsked = false

  init(status: PermissionsRequestResult) {
    self.status = status
  }

  func getAuthorizationStatus() async -> PermissionsRequestResult {
    status
  }

  func requestAuthorization() async -> Bool {
    hasAsked = true
    status = .authorized
    return true
  }

  func hasRequestedPermission() -> Bool {
    hasAsked
  }

  func openSettings() {}

  func recommendedAction() async -> PermissionsAction {
    if status == .authorized {
      return .none
    }
    if hasRequestedPermission() {
      return .openSettings
    }
    return .request
  }
}
