//
//  PermissionsServiceTests.swift
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

@testable import Permissable
import XCTest

final class PermissionsServiceTests: XCTestCase {

  // MARK: - Property Tests

  func testInitialization() {
    let service = PermissionsService(identifier: "Coffee", description: "Drinking Coffee Permission")

    XCTAssertEqual(service.identifier, "Coffee", "Expected the identifier to be 'camera'")
    XCTAssertEqual(service.description, "Drinking Coffee Permission", "Expected the description to be 'Dronking Coffeee Permission'")
  }

  func testEquality() {
    let service1 = PermissionsService(identifier: "camera", description: "Camera Permission")
    let service2 = PermissionsService(identifier: "camera", description: "Camera Permission")
    let service3 = PermissionsService(identifier: "microphone", description: "Microphone Permission")

    XCTAssertEqual(service1, service2, "Services with the same identifier and description should be equal")
    XCTAssertNotEqual(service1, service3, "Services with different identifiers or descriptions should not be equal")
  }

  func testHashable() {
    let service1 = PermissionsService(identifier: "camera", description: "Camera Permission")
    let service2 = PermissionsService(identifier: "camera", description: "Camera Permission")
    let service3 = PermissionsService(identifier: "microphone", description: "Microphone Permission")

    var servicesSet = Set<PermissionsService>()
    servicesSet.insert(service1)
    servicesSet.insert(service2)
    servicesSet.insert(service3)

    XCTAssertEqual(servicesSet.count, 2, "Expected set to contain 2 unique services")
  }

  // MARK: - Default Tests

  func testDefaultCameraService() {
    let camera = PermissionsService.camera
    XCTAssertEqual(
      camera.identifier,
      "camera",
      "Expected default camera service identifier to be 'camera'"
    )
    XCTAssertEqual(
      camera.description,
      "Camera Access",
      "Expected default camera service description to be 'Camera Access'"
    )
  }

  func testDefaultMicrophoneService() {
    let microphone = PermissionsService.microphone
    XCTAssertEqual(
      microphone.identifier,
      "microphone",
      "Expected default microphone service identifier to be 'microphone'"
    )
    XCTAssertEqual(
      microphone.description,
      "Microphone Access",
      "Expected default microphone service description to be 'Microphone Access'"
    )
  }

  func testDefaultPhotoLibraryService() {
    let photoLibrary = PermissionsService.photoLibrary
    XCTAssertEqual(
      photoLibrary.identifier,
      "photoLibrary",
      "Expected default photo library service identifier to be 'photoLibrary'"
    )
    XCTAssertEqual(
      photoLibrary.description,
      "Photo Library Access",
      "Expected default photo library service description to be 'Photo Library Access'"
    )
  }

  func testDefaultNotificationsService() {
    let notifications = PermissionsService.notifications
    XCTAssertEqual(
      notifications.identifier,
      "notifications",
      "Expected default notifications service identifier to be 'notifications'"
    )
    XCTAssertEqual(
      notifications.description,
      "Push Notifications Access",
      "Expected default notifications service description to be 'Push Notifications Access'"
    )
  }
}
