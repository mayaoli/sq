//
//  test01EmployeeServiceTests.swift
//  EmployeesTests
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import XCTest
@testable import Employees

class test01EmployeeServiceTests: XCTestCase {

  private let timeoutInterval = 10.0
  private let epServices = EmployeeServices()
  
  override func setUp() {
      super.setUp()
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
  }

  func testServiceSuccessCase() {
    let exp = expectation(description: "**** testServiceSuccessCase")
      
    let _ = self.epServices.getList{ (list, error) in
      XCTAssertNotNil(list)
      XCTAssert(list[0].employeeID == "0d8fcc12-4d0c-425c-8355-390b312b909c")
      XCTAssert(list[0].fullName == "Justine Mason")
      // there could be more properties check here
      XCTAssertNil(error)
      //
      exp.fulfill()
    }
      
    waitForExpectations(timeout: timeoutInterval, handler: nil)
  }

  func testServiceEmptyCase() {
    let exp = expectation(description: "**** testServiceEmptyCase")
      
    self.epServices.forTest = .empty
    let _ = self.epServices.getList{ (list, error) in
      XCTAssertNil(error)
      XCTAssert(list.count == 0)
      //
      exp.fulfill()
    }
  }

  func testServiceFailedCase() {
    let exp = expectation(description: "**** testServiceFailedCase")
      
    self.epServices.forTest = .failed
    let _ = self.epServices.getList{ (list, error) in
      XCTAssertNotNil(error)
      XCTAssert(list.count == 0)
      //
      exp.fulfill()
    }
  }
  
  func testEmployeeDataModel() {
    let exp = expectation(description: "**** testEmployeeDataModel")
    // TODO
    XCTAssert(true)
    exp.fulfill()
  }

  func testPerformanceExample() {
      // This is an example of a performance test case.
      self.measure {
          // Put the code you want to measure the time of here.
      }
  }

}
