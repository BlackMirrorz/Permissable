//  ContentView.swift
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

struct ContentView: View {

  @StateObject private var permissionsClient = PermissionsClient()

  private let services: [PermissionsService] = [
    .camera,
    .microphone,
    .photoLibrary,
    .notifications
  ]

  // MARK: - Body

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack {
        Text(Constants.header).font(.title).fontWeight(.heavy).foregroundStyle(.white)
        ForEach(services, id: \.self) { service in
          PermissionsRow(service: service, permissionsClient: permissionsClient)
        }
        Spacer()
        character.overlay { settingsView }
      }.padding()
    }.overlay { SplashScreen() }
      .onAppear { Task { await permissionsClient.checkCurrentStatuses() } }
  }

  // MARK: - Character

  private var character: some View {
    HStack {
      Spacer()
      Image(Constants.characterImage)
        .resizable()
        .frame(width: 60, height: 70)
        .scaleEffect(x: -1, y: 1, anchor: .center)
    }
  }

  // MARK: - Settings

  private var settingsView: some View {
    ButtonBuilder.build(
      title: Constants.openSettings,
      action: { permissionsClient.openSettings(for: .camera) }
    )
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
