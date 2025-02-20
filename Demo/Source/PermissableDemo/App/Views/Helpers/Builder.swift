//
//  Builder.swift
//  PermissableDemo
//
//  Created by Josh Robbins on 2/20/25.
//

import SwiftUI

enum ButtonBuilder {

  static func build(title: String, action: @escaping () -> Void) -> some View {
    Button(
      action: {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        action()
      }) {
        Text(title)
          .font(.subheadline)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(.white)
          .background(Color.clear)
          .cornerRadius(8)
      }
      .buttonStyle(.bordered)
      .frame(height: 50)
      .fixedSize()
  }
}
