//
//  PermissionsService+Extensions.swift
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

extension PermissionsService {

  enum Icon: String {
    case camera = "camera.circle"
    case microphone = "microphone.circle"
    case photoLibrary = "photo.circle"
    case pushNotification = "bell.circle"
  }

  var icon: Icon {
    switch self {
    case .camera:
      return .camera
    case .microphone:
      return .microphone
    case .photoLibrary:
      return .photoLibrary
    case .notifications:
      return .pushNotification
    default:
      fatalError("Unsupported Icon")
    }
  }
}
