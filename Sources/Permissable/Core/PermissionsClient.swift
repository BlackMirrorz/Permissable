//
//  PermissionsClient.swift
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
import SwiftUI

public final class PermissionsClient: PermissionsClientProtocol, ObservableObject, @unchecked Sendable {

  @Published public private(set) var permissionStatuses: [PermissionsService: PermissionsRequestResult] = [:]

  private var providers: [PermissionsService: any PermissionsValidatorProtocol]

  private var logger: (any PermissionsLoggerProtocol)?

  private let notificationCenter: NotificationCenter

  public var permissionStatusResolver: @Sendable (PermissionsService) -> Bool {
    return { [weak self] service in
      guard let self = self else { return false }
      return self.permissionStatuses[service] == .authorized
    }
  }

  private var cancellables: Set<AnyCancellable> = []

  // MARK: - Initialization

  public init(
    providers: [PermissionsService: any PermissionsValidatorProtocol] = PermissionsClient.defaultProviders,
    logger: PermissionsLoggerProtocol = PermissionsLogger(),
    notificationCenter: NotificationCenter = .default
  ) {
    self.providers = providers
    self.logger = logger
    self.notificationCenter = notificationCenter

    for (service, _) in providers {
      permissionStatuses[service] = .notDetermined
    }
    Task { await self.checkCurrentStatuses() }
    observeApplicationState()
  }

  // MARK: - Additional Registration

  func registerProviders(_ newProviders: [PermissionsService: any PermissionsValidatorProtocol]) {
    providers = providers.merging(newProviders) { _, new in new }

    for (service, _) in providers {
      if permissionStatuses[service] == nil {
        permissionStatuses[service] = .notDetermined
      }
    }

    Task { await self.checkCurrentStatuses() }
  }
}

// MARK: - Permissions

extension PermissionsClient {

  @MainActor
  public func checkCurrentStatuses() async {
    for (service, validator) in providers {
      let status = await validator.getAuthorizationStatus()
      permissionStatuses[service] = status
      logger?.logMessage(type: .info, message: "Service \(service.identifier) status: \(status)")
    }
  }

  @MainActor
  public func requestAuthorization(for type: PermissionsService) async throws {
    guard
      let validator = providers[type]
    else {
      throw PermissionsClientError.validatorNotFound(validator: type)
    }
    let granted = await validator.requestAuthorization()
    let status = await validator.getAuthorizationStatus()
    permissionStatuses[type] = status
    logger?.logMessage(type: .info, message: "Service \(type.identifier) request result: \(granted)")
  }

  public func hasAskedForPermission(for type: PermissionsService) -> Bool {
    guard let validator = providers[type] else { return false }
    return validator.hasRequestedPermission()
  }

  @MainActor
  public func recommendedAction(for service: PermissionsService) async -> PermissionsAction {
    guard let validator = providers[service] else { return .none }
    return await validator.recommendedAction()
  }
}

// MARK: - Application State

extension PermissionsClient {

  private func observeApplicationState() {
    let didBecomeActiveClosure: @Sendable (Notification) -> Void = { [weak self] _ in
      Task { await self?.checkCurrentStatuses() }
    }

    notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink(receiveValue: didBecomeActiveClosure)
      .store(in: &cancellables)
  }
}

// MARK: - Settings

extension PermissionsClient {

  @MainActor
  public func openSettings(for type: PermissionsService) {
    guard let validator = providers[type] else { return }
    validator.openSettings()
    logger?.logMessage(type: .info, message: "Opened settings for service \(type.identifier)")
  }
}

// MARK: - Default Providers

extension PermissionsClient {

  public static var defaultProviders: [PermissionsService: any PermissionsValidatorProtocol] {
    [
      .camera: CameraPermissionsValidator(),
      .microphone: MicrophonePermissionsValidator(),
      .photoLibrary: PhotoLibraryPermissionsValidator(),
      .notifications: PushNotificationPermissionsValidator()
    ]
  }
}
