//
//  PermissionsRow.swift
//  PermissableDemo
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

import Permissable
import SwiftUI

struct PermissionsRow: View {

  let service: PermissionsService
  @ObservedObject var permissionsClient: PermissionsClient
  @State private var action: PermissionsAction = .request
  @State private var statusScale: CGFloat = 1.0
  @State private var isPermissable = false

  // MARK: - Body

  var body: some View {
    HStack {
      iconStatusTextView
      Spacer()
      statusView
    }.frame(height: 50).frame(maxWidth: .infinity, alignment: .leading)
      .onChange(of: permissionsClient.permissionStatuses) { _ in syncStatus() }
      .onChange(of: isPermissable) { processScale($0) }
      .onAppear { syncStatus() }
  }
}

// MARK: - ViewBuilders

extension PermissionsRow {

  @ViewBuilder
  private var iconStatusTextView: some View {
    iconView.scaleEffect(statusScale).animation(.bouncy(extraBounce: 0.2), value: statusScale)
    statusTextView
  }

  @ViewBuilder
  private var statusTextView: some View {
    let rootText = permissionsClient.permissionStatuses[service]?.statusText ?? ""

    Text(rootText)
      .font(Constants.statusFont)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundStyle(permissionsClient.permissionStatusResolver(service) ? .green : .red)
      .accessibilityIdentifier(service.identifier + "-" + rootText)
  }

  private var iconView: some View {
    Image(systemName: service.icon.rawValue)
      .font(Constants.iconFont)
      .foregroundStyle(.white)
  }

  @ViewBuilder
  private var statusView: some View {
    Group {
      switch action {
      case .request:
        genericButton(
          title: Constants.ask,
          action: { requestAuthorization() }
        )
      case .openSettings:
        genericButton(
          title: Constants.openSettings,
          action: { openSettings() }
        )
      case .none:
        EmptyView()
      }
    }.transition(.scale)
      .animation(.bouncy(duration: 0.5), value: action)
  }

  private func genericButton(title: String, action: @escaping (() -> Void)) -> some View {
    ButtonBuilder.build(
      title: title,
      action: action
    ).accessibilityIdentifier(service.identifier + "-" + title)
  }
}

// MARK: - Callbacks

extension PermissionsRow {

  private func syncStatus() {
    Task {
      action = await permissionsClient.recommendedAction(for: service)
      await MainActor.run {
        isPermissable = action == .none
      }
    }
  }

  private func requestAuthorization() {
    Task {
      try? await permissionsClient.requestAuthorization(for: service)
    }
  }

  private func openSettings() {
    permissionsClient.openSettings(for: service)
  }

  private func processScale(_ value: Bool) {
    withAnimation {
      if value {
        statusScale = 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          statusScale = 1.0
        }
      }
    }
  }
}
