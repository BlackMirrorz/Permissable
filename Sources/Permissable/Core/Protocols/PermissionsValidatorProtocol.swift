//
//  PermissionsValidatorProtocol.swift
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

import UIKit

/**
 Protocol defining the behavior for managing a specific app  permissions.

 Any type conforming to this protocol is responsible for handling  the request and management of a specific permission type.

 - Requirements:
   - Define how the permission's current status is retrieved. getAuthorizationStatus() -> PermissionRequestResult
   - Provide a method to request authorization.
   - Determine if the permission has been previously requested.
   - Offer a way to open the app's settings for the user to manually adjust permissions.
 */
public protocol PermissionsValidatorProtocol {

  /**
   Retrieves the current authorization status for the permission.

   - Returns: The current status of the permission as a `PermissionType`.
   - Possible values:
     - `notDetermined`: Permission has not been requested yet.
     - `restricted`: Permission is restricted by system policies or parental controls.
     - `denied`: Permission was explicitly denied by the user.
     - `limited`: Permission was granted with limited access (if applicable).
     - `authorized`: Full access to the permission has been granted.
   */
  func getAuthorizationStatus() async -> PermissionsRequestResult

  /**
   Requests authorization for the permission asynchronously.

   - Returns: A `Bool` indicating whether the permission was granted (`true`) or denied (`false`).
   - Notes: The method should prompt the system's authorization dialog, if necessary.
   */
  func requestAuthorization() async -> Bool

  /**
   Checks if the permission has been requested before.

   - Returns: A `Bool` indicating whether the permission has already been requested (`true`) or not (`false`).
   - Notes: This method does not determine the current status of the permission but simply
            checks if the app has already prompted the user for this specific permission.
   */
  func hasRequestedPermission() -> Bool

  /**
   Computes the recommended action based on the current authorization status and whether the permission has been requested before.

   - Returns: A `PermissionAction` indicating whether to request the permission, prompt the user to open settings, or do nothing.

   The default behavior is:
   - If the permission is authorized, return `.none`.
   - If the permission is not authorized and has already been requested, return `.openSettings`.
   - Otherwise, return `.request`.
   */
  func recommendedAction() async -> PermissionsAction

  /**
   Opens the app's settings page to allow the user to adjust permissions manually.
   */
  @MainActor
  func openSettings()
}

// MARK: - Default Implementation

extension PermissionsValidatorProtocol {

  @MainActor
  public func openSettings() {
    guard
      let settingsURL = URL(string: UIApplication.openSettingsURLString),
      UIApplication.shared.canOpenURL(settingsURL)
    else {
      return
    }
    UIApplication.shared.open(settingsURL)
  }

  public func recommendedAction() async -> PermissionsAction {
    let status = await getAuthorizationStatus()
    if status == .authorized {
      return .none
    }
    if hasRequestedPermission() {
      return .openSettings
    }
    return .request
  }
}
