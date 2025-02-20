//
//  SplashScreen.swift
//  PermissableDemo
//
//  Created by Josh Robbins on 2/19/25.
//

import SwiftUI

struct SplashScreen: View {

  @State private var imageOpacity: CGFloat = 1
  @State private var viewOpacity: CGFloat = 1
  private let isIPAD = UIDevice.current.userInterfaceIdiom == .pad

  // MARK: - Body

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        let size = isIPAD ? 450 : proxy.size.width - 32
        Group {
          Color.black.ignoresSafeArea()
          VStack {
            Spacer()
            imageView(size).opacity(imageOpacity)
            Spacer()
          }
        }.opacity(viewOpacity)
      }
    }.onAppear { fadeOffScreen() }
  }

  // MARK: - ViewBuilders

  private func imageView(_ size: CGFloat) -> some View {
    HStack {
      Spacer()
      Image("permissableSplashScreen")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: size, height: size)
      Spacer()
    }.id(1)
  }
}

// MARK: - Callbacks

extension SplashScreen {

  private func fadeOffScreen() {
    withAnimation(.easeOut(duration: 3)) { imageOpacity = 0 }

    withAnimation(.easeInOut(duration: 2).delay(3)) {
      viewOpacity = 0
    }
  }
}

// MARK: - Preview

#Preview {
  SplashScreen()
}
