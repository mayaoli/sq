//
//  test00BaseServiceTests.swift
//  EmployeesTests
//
//  Created by YM on 2020-02-11.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import XCTest

class test00BaseServiceTests: XCTestCase {

    private var timeoutInterval = 10.0
    private var networking = BaseServices()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        timeoutInterval = 10.0
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //MARK:- Success Cases
    
    /// Test simple get request
    func testSimpleGetSuccess() {
        let exp = expectation(description: "testSimpleGetSuccess")
        
        let url = URL(string: "https://httpbin.org/get")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            XCTAssertNotNil(data, "Data is nil")
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }

    /// Test network reachability success
    func testNetworkingReachabilitySuccess() {
        let exp = expectation(description: "testNetworkingReachability")
        
        let url = URL(string: "https://httpbin.org/get")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssert(error != .noInternet, "Incorrect error thrown.")
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    //MARK:- Fail Cases
    
    /// Test response validation error
    func testNetworkingResponseValidationFail() {
        let exp = expectation(description: "testNetworkingResponseValidationFailed")
        
        let url = URL(string: "https://httpbin.org/get")!
        let _ = networking.post(url: url) { (response, data, error) in
            XCTAssertNotNil(error)
            XCTAssert(error == NetworkingError.responseValidationFailed, "Incorrect Error type")
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test invalid url request validation error
    func testNetworkURLErrorFail() {
        let exp = expectation(description: "testNetworkURLError")
        
        let url = URL(string: "https://")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssertNotNil(error)
            XCTAssert(error == NetworkingError.requestValidationFailed, "Incorrect Error type")
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }

    /// Test response data returned as nil
    func testParseDataNilFail() {
        let exp = expectation(description: "testParseDataNil")
        
        let url = URL(string: "https://httpbin.org/image/jpeg")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssertNil(data, "Data is not nil.")
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    //MARK:- SuccessFail Cases
    
    /// Test query params passed in post request
    func testPostQueryParametersSuccessFail() {
        let exp = expectation(description: "testPostQueryParameters")
        
        let url = URL(string: "https://httpbin.org/post?foo=wrong")!
        let params = ["foo": "bar", "hello": "world"]
        let _ = networking.post(url: url, queryParameters: params, bodyParameters: nil, headers: nil) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let respData = data, let json = data?.json {
                XCTAssert(respData.type == .json, "Incorrect Data type")
                XCTAssert(json["url"] == "https://httpbin.org/post?foo=bar&hello=world", "Incorrect URL serialization")
            } else {
                XCTAssertNotNil(data, "Data is nil")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test query params passed in get request
    func testGetQueryParametersSuccessFail() {
        let exp = expectation(description: "testGetQueryParameters")
        
        let url = URL(string: "https://httpbin.org/get")!
        let params = ["foo": "bar"]
        let _ = networking.get(url: url, queryParameters: params, headers: nil) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let respData = data, let json = data?.json {
                XCTAssert(respData.type == .json, "Incorrect Data type")
                XCTAssert(json["url"] == "https://httpbin.org/get?foo=bar", "Incorrect URL serialization")
            } else {
                XCTAssertNotNil(data, "Data is nil")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test body params passed in post request as JSON
    func testPostBodyJsonParametersSuccessFail() {
        let exp = expectation(description: "testPostBodyJsonParameters")
        
        let url = URL(string: "https://httpbin.org/post")!
        let bodyParams = ["foo": "bar"]
        let _ = networking.post(url: url, queryParameters: nil, bodyParameters: bodyParams, headers: nil, contentType: .json) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let respData = data, let json = data?.json {
                XCTAssert(respData.type == .json, "Incorrect Data type")
                XCTAssert(json["json"]["foo"] == "bar", "Incorrect body type. Requires JSON.")
            } else {
                XCTAssertNotNil(data, "Data is nil")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test body params passed in post request as form-data
    func testPostBodyFormParametersSuccessFail() {
        let exp = expectation(description: "testPostBodyFormParameters")
        
        let url = URL(string: "https://httpbin.org/post")!
        let bodyParams = ["foo": "bar"]
        let _ = networking.post(url: url, queryParameters: nil, bodyParameters: bodyParams, headers: nil, contentType: .form) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let respData = data, let json = data?.json {
                XCTAssert(respData.type == .json, "Incorrect Data type")
                XCTAssert(json["form"]["foo"] == "bar", "Incorrect body type. Requires form data.")
            } else {
                XCTAssertNotNil(data, "Data is nil")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test header params passed in post request
    func testHeaderInPostRequestSuccessFail() {
        let exp = expectation(description: "testHeaderInPostRequest")
        
        let url = URL(string: "https://httpbin.org/post")!
        let _ = networking.post(url: url, queryParameters: nil, bodyParameters: nil, headers: ["foo": "bar"]) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let respData = data, let json = data?.json {
                XCTAssert(respData.type == .json, "Incorrect Data type")
                XCTAssert(json["headers"]["Foo"] == "bar", "Incorrect header serialization.")
            } else {
                XCTAssertNotNil(data, "Data is nil")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)

    }
    
    /// Test response data returned as XML
    func testParseDataXMLSuccessFail() {
        let exp = expectation(description: "testXMLResponse")
        
        let url = URL(string: "https://httpbin.org/xml")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let responseData = data {
                XCTAssert(responseData.type == .xml, "Response type is not XML")
            } else {
                XCTFail("Data is nil.")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test response data returned as JSON
    func testParseDataJSONSuccessFail() {
        let exp = expectation(description: "testJSONResponse")
        
        let url = URL(string: "https://httpbin.org/get")!
        let _ = networking.get(url: url) { (response, data, error) in
            XCTAssertNil(error)
            XCTAssert(response?.statusCode == 200, "HTTP status code is not 200.")
            if let responseData = data {
                XCTAssert(responseData.type == .json, "Response type is not JSON")
            } else {
                XCTFail("Data is nil.")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }
    
    /// Test response data returned as String
    func testParseDataStringSuccessFail() {
        let exp = expectation(description: "testStringResponse")
        
        let url = URL(string: "https://httpbin.org/get")!
        let _ = networking.post(url: url) { (response, data, error) in
            XCTAssertNotNil(error)
            if let responseData = data {
                XCTAssert(responseData.type == .string, "Response type is not String")
            } else {
                XCTFail("Data is nil.")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval, handler: nil)
    }

}
