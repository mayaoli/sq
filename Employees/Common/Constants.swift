//
//  Constants.swift
//  myFancyCars
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli Ma. All rights reserved.
//

import Foundation
import SwiftyJSON
import SWXMLHash
import SDWebImage

struct Constants {
  static let BUNDLE_NUMBER = 10
  static let BASE_URL = "https://s3.amazonaws.com/sq-mobile-interview"
  static let STORAGE_PATH: String = "CachedObject"
}

// For a single view application, there is really no need to define so many enums.
// However, here is to show how the project should be structured

enum NetworkingError: Error {
  
  // MARK: Error Cases
  
  /// Unknown of generic error
  case unknown
  /// If no internet is detected
  case noInternet
  /// Request validation failed when making a network call.
  case requestValidationFailed
  /// Response validation failed after making a network call.
  case responseValidationFailed
  /// Request or Response encoding failed
  case encodingFailed
  
  
  var debugDescription: String {
    switch self {
    case .unknown:
      return "An unknown error has occurred."
    case .noInternet:
      return "No Internet connectivity. Reason: Check your network or Service not reachable."
    case .requestValidationFailed:
      print("Request validation failed. Reason: Invalid URL, incorrect request parameters, headers, http method, etc.")
      return "Technical issue"
    case .responseValidationFailed:
      print("Response validatation failed. Reason: Data file nil, missing or unacceptable ContentType, serialization failed or unacceptable status code.")
      return "Technical issue"
    case .encodingFailed:
      print("Parameter or Multi-part encoding failed. Reason: Missing URL, json/plist encoding failed, stream read/write failed, etc.")
      return "Technical issue"
    }
  }
}

enum UnitTestType {
  case none
  case empty
  case failed
//  case timeout
//  case validation
}

enum ContentType {
  case json
  case form
}

enum Method: String {
  case GET
  case POST
}

enum NetworkStatus {
  case reachable
  case notReachable
  case unknown
}

enum SortName {
  case name
  case availability
}

struct NetworkErrorInformation {
  
  let httpStatusCode: Int
  let statusCodes: [String]
  
  init?(json: JSON) {
    
    let statusInformation = json["status"].dictionaryValue
    
    guard let httpStatusCode = statusInformation["httpStatusCode"]?.int else {
      return nil
    }
    
    guard let statusCodes = statusInformation["details"]?.array, !statusCodes.isEmpty else {
      return nil
    }
    
    let codes = statusCodes.compactMap { $0["statusCode"].string }
    
    self.httpStatusCode = httpStatusCode
    self.statusCodes = codes
    
  }
  
  init?(httpURLResponse: HTTPURLResponse, error: Error){
    httpStatusCode = httpURLResponse.statusCode
    statusCodes = [String((error as NSError).code)]
  }
  
  init?(error: Error){
    httpStatusCode = 0
    statusCodes = [String((error as NSError).code)]
  }
  
  init?(error: NetworkingError){
    httpStatusCode = 0
    statusCodes = [String((error as NSError).code)]
  }
}

struct ResponseData {
  enum DataType {
    case json
    case xml
    case string
    case data
  }
  
  var type: DataType
  var json: JSON?
  var xml: XMLIndexer?
  var string: String?
  var data: Data
}

