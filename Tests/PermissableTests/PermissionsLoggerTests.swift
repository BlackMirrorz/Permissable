//
//  PermissionsLoggerTests.swift
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

@testable import Permissable
import XCTest

final class PermissionsLoggerTests: XCTestCase {

  func testLogMessageInfo() {
    let mockLogger = TestPermissionsLogger()
    let testMessage = "Test info message"
    mockLogger.logMessage(type: .info, message: testMessage)

    XCTAssertEqual(mockLogger.loggedMessages.count, 1, "Expected one logged message")
    let (loggedType, loggedMessage) = mockLogger.loggedMessages[0]
    XCTAssertEqual(loggedType, .info, "Expected log type to be info")
    XCTAssertEqual(loggedMessage, testMessage, "Logged message should match the test message")
  }

  func testLogMessageSuccess() {
    let mockLogger = TestPermissionsLogger()
    let testMessage = "Test success message"
    mockLogger.logMessage(type: .success, message: testMessage)

    XCTAssertEqual(mockLogger.loggedMessages.count, 1, "Expected one logged message")
    let (loggedType, loggedMessage) = mockLogger.loggedMessages[0]
    XCTAssertEqual(loggedType, .success, "Expected log type to be success")
    XCTAssertEqual(loggedMessage, testMessage, "Logged message should match the test message")
  }

  func testLogMessageWarning() {
    let mockLogger = TestPermissionsLogger()
    let testMessage = "Test warning message"
    mockLogger.logMessage(type: .warning, message: testMessage)

    XCTAssertEqual(mockLogger.loggedMessages.count, 1, "Expected one logged message")
    let (loggedType, loggedMessage) = mockLogger.loggedMessages[0]
    XCTAssertEqual(loggedType, .warning, "Expected log type to be warning")
    XCTAssertEqual(loggedMessage, testMessage, "Logged message should match the test message")
  }

  func testPermissionsLoggerDoesNotCrash() {
    let logger = PermissionsLogger()
    logger.logMessage(type: .info, message: "OSLog info test")
    logger.logMessage(type: .success, message: "OSLog success test")
    logger.logMessage(type: .warning, message: "OSLog warning test")
  }
}

// MARK: - Mocks

final class TestPermissionsLogger: PermissionsLoggerProtocol {
  var loggedMessages: [(type: LogType, message: String)] = []

  func logMessage(type: LogType, message: String) {
    loggedMessages.append((type: type, message: message))
  }
}
