//
//  PermissionsService.swift
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

/**
 A struct representing a specific permission service in the application.

 Use this struct to represent a particular permission requirement (for example, camera, microphone, or photo library access).

 The service is marked as Sendable since it is entirely immutable
 */
public struct PermissionsService: Hashable, Sendable {

  /// A unique string identifier for the permission service.
  public let identifier: String

  /// A human-readable description of the permission service.
  public let description: String

  /**
   Initializes a new `PermissionsService`.

   - Parameters:
     - identifier: A unique string identifier for the service.
     - description: A human-readable description of the service.
   */
  public init(identifier: String, description: String) {
    self.identifier = identifier
    self.description = description
  }
}

// MARK: - PreDefined Services

extension PermissionsService {

  /// Permission service for accessing the camera.
  public static let camera = PermissionsService(
    identifier: "camera",
    description: "Camera Access"
  )

  /// Permission service for accessing the microphone.
  public static let microphone = PermissionsService(
    identifier: "microphone",
    description: "Microphone Access"
  )

  /// Permission service for accessing the photo library.
  public static let photoLibrary = PermissionsService(
    identifier: "photoLibrary",
    description: "Photo Library Access"
  )

  /// Permission service forPushNotifications.
  public static let notifications = PermissionsService(
    identifier: "notifications",
    description: "Push Notifications Access"
  )
}
