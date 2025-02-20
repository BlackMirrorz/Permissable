//
//  PermissionsClientErrorTests.swift
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

final class PermissionClientErrorTests: XCTestCase {

  func testDescription() {
    let service = PermissionsService(identifier: "testService", description: "Test Service")
    let error = PermissionsClientError.validatorNotFound(validator: service)
    let expectedDescription = "No validator found for testService (Test Service)"
    XCTAssertEqual(error.description, expectedDescription, "Error description should match expected string.")
  }

  func testEquatability() {
    let service1 = PermissionsService(identifier: "testService", description: "Test Service")
    let service2 = PermissionsService(identifier: "testService", description: "Test Service")

    let error1 = PermissionsClientError.validatorNotFound(validator: service1)
    let error2 = PermissionsClientError.validatorNotFound(validator: service2)

    XCTAssertEqual(error1, error2, "Two validatorNotFound errors with equivalent services should be equal.")
  }

  func testInequality() {
    let service1 = PermissionsService(identifier: "testService1", description: "Test Service 1")
    let service2 = PermissionsService(identifier: "testService2", description: "Test Service 2")

    let error1 = PermissionsClientError.validatorNotFound(validator: service1)
    let error2 = PermissionsClientError.validatorNotFound(validator: service2)

    XCTAssertNotEqual(error1, error2, "Errors with different services should not be equal.")
  }
}
