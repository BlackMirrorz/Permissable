//
//  PushNotificationPermissionsValidator.swift
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

import UserNotifications

public final class PushNotificationPermissionsValidator: PermissionsValidatorProtocol {

  public func getAuthorizationStatus() async -> PermissionsRequestResult {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        let result: PermissionsRequestResult
        switch settings.authorizationStatus {
        case .notDetermined:
          result = .notDetermined
        case .denied:
          result = .denied
        case .authorized, .provisional, .ephemeral:
          result = .authorized
        @unknown default:
          fatalError("Unknown push notification authorization status.")
        }
        continuation.resume(returning: result)
      }
    }
  }

  public func requestAuthorization() async -> Bool {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
        continuation.resume(returning: granted)
      }
    }
  }

  public func hasRequestedPermission() -> Bool {
    var result: PermissionsRequestResult = .notDetermined
    let semaphore = DispatchSemaphore(value: 0)
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .notDetermined:
        result = .notDetermined
      case .denied:
        result = .denied
      case .authorized, .provisional, .ephemeral:
        result = .authorized
      @unknown default:
        fatalError("Unknown push notification authorization status.")
      }
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 5)
    return result != .notDetermined
  }
}
