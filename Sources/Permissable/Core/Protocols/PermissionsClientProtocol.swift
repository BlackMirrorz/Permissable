//
//  PermissionsClientProtocol.swift
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

import SwiftUI

/**
 A protocol for coordinating and managing app permissions.

 This protocol defines the requirements for checking and requesting various permissions
 (such as camera, microphone, and photo library). Classes or structs adopting this protocol
 must provide mechanisms to manage permission statuses and handle user authorization requests.

 - Conforms to: `ObservableObject` for SwiftUI state management.
 */
protocol PermissionsClientProtocol: ObservableObject, AnyObject {

  /**
   A resolver that returns whether permission is granted for a given service.

   The resolver is a convenience closure that computes a Boolean value based on the underlying
   permission status for the provided service.
   */
  var permissionStatusResolver: @Sendable (PermissionsService) -> Bool { get }

  /**
   A read-only dictionary mapping each permission service to its current authorization status.

   This property allows external consumers (such as SwiftUI views) to observe the current statuses.
   The implementing type is responsible for updating this dictionary when permission statuses change.
   */
  var permissionStatuses: [PermissionsService: PermissionsRequestResult] { get }

  /**
   Requests authorization for a specific service.

   This method triggers a permission prompt for the specified service (e.g., camera, microphone).
   The method should run on the main actor to ensure any UI-related operations are executed on the main thread.

   - Parameter type: The type of service for which permission is being requested.
   - Throws: An error if the authorization request fails or is not granted.
   */
  @MainActor
  func requestAuthorization(for type: PermissionsService) async throws

  /**
   Checks if the user has already been prompted for a specific permission.

   This method determines whether the app has previously asked the user for authorization for a specific service.

   - Parameter type: The type of service to check.
   - Returns: `true` if the app has already asked for permission, `false` otherwise.
   */
  func hasAskedForPermission(for type: PermissionsService) -> Bool

  /**
   Determines the recommended action for the specified permission service.

   - Parameter service: The permission service to evaluate.
   - Returns: A `PermissionAction` indicating whether to request permission, open settings, or do nothing.
   */
  @MainActor
  func recommendedAction(for service: PermissionsService) async -> PermissionsAction
}

// MARK: - Default Helpers

extension PermissionsClientProtocol {
  /**
   Returns whether permission is granted for the specified service.

   - Parameter type: The service for which permission is being queried.
   - Returns: `true` if permission is granted, `false` otherwise.
   */
  func isPermissionGranted(for type: PermissionsService) -> Bool {
    permissionStatusResolver(type)
  }
}
