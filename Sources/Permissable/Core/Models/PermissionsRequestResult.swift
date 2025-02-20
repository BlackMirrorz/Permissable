//
//  PermissionsRequestResult.swift
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

import Foundation

/**
 Generic result of a PermissionsRequest.

 - notDetermined: The user has not yet been asked for the permission.
 - restricted: The permission is restricted, possibly due to parental controls or system policy.
 - denied: The user has explicitly denied the permission.
 - limited: The user granted limited access to the permission (applies to certain types, such as the photo library).
 - authorized: The user has granted full access to the permission.
 */
public enum PermissionsRequestResult: Equatable, CaseIterable, Sendable {
  case notDetermined
  case restricted
  case denied
  case limited
  case authorized
}

// MARK: - UI Helpers

extension PermissionsRequestResult {

  /**
   A user-friendly text description of the permission status.
   - Returns: A string representation of the permission status:
     - "Authorized" if full access is granted.
     - "Denied" if the permission has been explicitly denied.
     - "Not Determined" if the user has not yet been asked.
     - "Restricted" if access is restricted by system policies or parental controls.
     - "Limited" if only limited access is granted.
   */
  public var statusText: String {
    switch self {
    case .authorized:
      return "Authorized"
    case .denied:
      return "Denied"
    case .notDetermined:
      return "Not Determined"
    case .restricted:
      return "Restricted"
    case .limited:
      return "Limited"
    }
  }
}
