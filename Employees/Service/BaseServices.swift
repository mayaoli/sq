//
//  BaseServices.swift
//  myFancyCars
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli Ma. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SWXMLHash


protocol JSONModel {
  init(json: JSON) throws
}

class BaseServices {
  
  // MARK: - TypeAliases
  typealias NetworkCompletionBlock = (_ response: HTTPURLResponse?, _ data: ResponseData?, _ error: NetworkingError?) -> Void
  //typealias NetworkInternetStatusListner = (_ status: NetworkStatus) -> Void
  
  
  // MARK: - Private Variables
  private var sessionManager: SessionManager
  
  // MARK: - Public Variables
  /// Set Listener block to lister for reachability status change.
  //var reachabilityListner: NetworkInternetStatusListner?
  
  // MARK: - Public Methods
  init() {
    
    sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    
  }
  
  /**
   Perform HTTP GET Request to retrieve the contents of the specified url, method, query parameters and headers.
   
   - parameter url: The URL to the request.
   - parameter queryParameters: Parameters to send as URL query.
   - parameter headers: Headers to send.
   - parameter completion: A response to an HTTP URL load, data returned in the response, and error if any. error is nil if successful data is returned.
   
   - returns: A resumed URLSessionTask if the request is triggered. You can use it to cancel, pause and re-resume the request.
   */
  func get(url: URL, queryParameters: [String: String]? = nil, headers: [String: String]? = nil, completion: @escaping NetworkCompletionBlock) -> URLSessionTask? {
    return request(url: url, method: .GET, parameters: queryParameters, headers: headers, contentType: nil, completion: completion)
  }
  
  /**
   Perform HTTP POST Request to retrieve the contents of the specified url, method, parameters and headers.
   
   - parameter url: The URL to the request.
   - parameter queryParameters: Parameters to send as URL query.
   - parameter bodyParameters: Parameters to send in the body.
   - parameter headers: Headers to send.
   - parameter contentType: Content yype of the body parameters. Send body as json, form-data, etc.
   - parameter completion: A response to an HTTP URL load, data returned in the response, and error if any. error is nil if successful data is returned.
   
   - returns: A resumed URLSessionTask if the request is triggered. You can use it to cancel, pause and re-resume the request.
   */
  func post(url: URL, queryParameters: [String: String]? = nil, bodyParameters: [String: Any]? = nil, headers: [String: String]? = nil, contentType: ContentType = .json, completion: @escaping NetworkCompletionBlock) -> URLSessionTask? {
    var newUrl = url
    if let queryParams = queryParameters {
      newUrl = addOrUpdateQueryStringParameter(url: newUrl, values: queryParams)
    }
    return request(url: newUrl, method: .POST, parameters: bodyParameters, headers: headers, contentType: contentType, completion: completion)
  }
  
  
  /**
   Get an array of serialized objects from a JSON array.
   
   Requires that the model inherits JSONModel because of Swift's contraints: "Constructing an object of class
   type 'T' with a metatype value must use a 'required' initializer")
   
   Meaning to add a required init method on BaseDataModel causes all models to break without syntax changes and
   adding said required init on some of them.
   
   - parameter jsonArray: The JSON array
   - parameter type: The type of object you want serialized
   - parameter transform: An optional transformation block to mutate each item upon instatiating it
   */
  func getArray<T: JSONModel>(_ jsonArray: JSON, type: T.Type, transform: ((_ item: T) -> Void)? = nil) throws -> [T] {
    var items: [T] = []
    for i in 0 ..< jsonArray.count {
      // Weird Swift syntax: you have to actually call init on something of type 'Type', you can't just use
      // type(json: ...)
      let item = try type.init(json: jsonArray[i])
      if let transform = transform {
        transform(item)
      }
      items.append(item)
    }
    return items
  }
  
  // MARK: - Private Methods
  
  /**
   Perform HTTP Request to retrieve the contents of the specified url, method, parameters and headers.
   
   - parameter url: The URL to the request.
   - parameter method: HTTP protocol to be used. GET, POST, etc.
   - parameter parameters: Parameters to send. Destination of parameters depends on the HTTP protocol. Get is in URL, POST is in body.
   - parameter headers: Headers to send.
   - parameter completion: A response to an HTTP URL load, data returned in the response, and error if any. error is nil if successful data is returned.
   
   - returns: A resumed URLSessionTask if the request is triggered. You can use it to cancel, pause and re-resume the request.
   */
  private func request(url: URL, method: Method, parameters: [String: Any]? = nil, headers: [String: String]? = nil, contentType: ContentType?, completion: @escaping NetworkCompletionBlock) -> URLSessionTask? {
    var frameworkMethod: Alamofire.HTTPMethod? = nil
    switch method {
    case .GET:
      frameworkMethod = Alamofire.HTTPMethod.get
    default:
      frameworkMethod = Alamofire.HTTPMethod.post
    }
    
    // TODO: improve performance
    // NetworkManager.sharedInstance.reachabilityStatus == .reachable
    guard let reachableMgr = NetworkManager.sharedInstance.reachabilityManager, reachableMgr.isReachable else {
      print(" 📡 Network Error: 📡 Not Reachable")
      // dismiss any loading screen
      completion(nil, nil, NetworkingError.noInternet)
      return nil
    }
    
    var encoding: ParameterEncoding = URLEncoding.default
    if (contentType != nil && contentType == .json) {
      encoding = JSONEncoding.default
    }
    
    let requestHeaders = headers
    
    let request = sessionManager.request(url, method: frameworkMethod!, parameters: parameters, encoding: encoding, headers: requestHeaders)
    
    let dataRequest = request.validate().response { (response) in
      
      let errorIfAny = self.logResponseAndReturnError(response: response)
      let dataIfAny = self.parseData(data: response.data)
      
      if dataIfAny == nil {
        
        if let error = errorIfAny,
          let networkErrorInformation = NetworkErrorInformation(error: error) {
          
          let codes = networkErrorInformation.statusCodes.joined(separator: ",")
          
          print(" ERROR \(codes): \(url)  CODE: \(networkErrorInformation.statusCodes.joined(separator: ","))")
          
        }
        
        completion(response.response, dataIfAny, errorIfAny)
        return
      }
      
      if let data = dataIfAny?.json,
        let networkErrorInformation = NetworkErrorInformation(json: data) {
        
        let codes = networkErrorInformation.statusCodes.joined(separator: ",")
      
        print(" ERROR \(codes): URL: \(url)  RESPONSE DATA: \(data) ")
      }
      
      completion(response.response, dataIfAny, errorIfAny)
    }
    return dataRequest.task
  }
  
  /**
   Add, update, or remove a query string item from the URL
   
   - parameter url: The URL
   - parameter key: The key of the query string item
   - parameter value: The value to replace the query string item, nil will remove item
   
   - returns: The URL with the mutated query string
   */
  private func addOrUpdateQueryStringParameter(url: URL, key: String, value: String?) -> URL {
    if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
      var queryItems: [URLQueryItem] = components.queryItems ?? []
      for (index, item) in queryItems.enumerated() {
        // Match query string key and update
        if item.name == key {
          if let v = value {
            queryItems[index] = URLQueryItem(name: key, value: v)
          } else {
            queryItems.remove(at: index)
          }
          components.queryItems = queryItems.count > 0 ? queryItems : nil
          return components.url!
        }
      }
      
      // If key doesn't exist
      if let v = value {
        // Add key to URL query string
        queryItems.append(URLQueryItem(name: key, value: v))
        components.queryItems = queryItems
        return components.url!
      }
    }
    return url
  }
  
  /**
   Add, update, or remove a query string parameters from the URL
   
   - parameter url: The URL
   - parameter values: The dictionary of query string parameters to replace
   
   - returns: The URL with the mutated query string
   */
  private func addOrUpdateQueryStringParameter(url: URL, values: [String: String]) -> URL {
    var newUrl = url
    for item in values {
      newUrl = addOrUpdateQueryStringParameter(url: newUrl, key: item.0, value: item.1)
    }
    return newUrl
  }
  
  /**
   Parse Response Data in to JSON, XML or String format.
   
   - parameter data: Data source to parse
   
   - returns: ResponseData object with type (json, xml, string) and appropriate variable populated. Returns nil if no Data found.
   */
  private func parseData(data: Data?) -> ResponseData? {
    guard data != nil && data!.count > 0 else {
      return nil
    }
    
    let json = JSON(data: data!)
    let xml = SWXMLHash.parse(data!)
    var isHTML = false;
    if (xml.element?.children.count ?? 0 > 0) {
      if let firstEle = xml.element?.children.first as? SWXMLHash.XMLElement {
        isHTML = (firstEle.name.caseInsensitiveCompare("html") == ComparisonResult.orderedSame)
      }
    }
    
    if json.type != .null {
      print(" 📡 \(json) 📡")
      return ResponseData(type: .json, json: json, xml: nil, string: nil, data: data!)
    } else if (xml.element?.children.count ?? 0 > 0 && !isHTML) {
        print(" 📡 \(xml) 📡")
      return ResponseData(type: .xml, json: nil, xml: xml, string: nil, data: data!)
    } else {
      if let respStr = String(data: data!, encoding: .utf8) {
        print(" 📡" + respStr + "📡")
        return ResponseData(type: .string, json: nil, xml: nil, string: respStr, data: data!)
      } else {
        print(" 📡 \(data.debugDescription) 📡")
        return nil
      }
    }
  }
  
  private func logResponseAndReturnError(response: DefaultDataResponse) -> NetworkingError? {
    
    //let statusCode = (response.response != nil) ? String(response.response!.statusCode) : "N/A"
    
    if response.error != nil {
      var networkingError: NetworkingError = .unknown
      
      if let afError = response.error as? AFError {
        switch afError {
        case .parameterEncodingFailed(reason: _):
          networkingError = .encodingFailed
        case .multipartEncodingFailed(reason: _):
          
          networkingError = .encodingFailed
        case .responseValidationFailed(reason: _):
          
          networkingError = .responseValidationFailed
        case .responseSerializationFailed(reason: _):
          
          networkingError = .responseValidationFailed
        case .invalidURL(url: _):
          
          networkingError = .requestValidationFailed
        }
      } else if let error = response.error as? URLError {
        
        if (error.errorCode == -1009) {
          networkingError = .noInternet
          NetworkManager.sharedInstance.reachabilityStatus = .notReachable
        } else {
          networkingError = .requestValidationFailed
          
        }
        networkingError = (error.errorCode == -1009) ? NetworkingError.noInternet : NetworkingError.requestValidationFailed
        
      } else {
        
        networkingError = .requestValidationFailed
      }
      
      print(" 📡 NETWORKING: 📡 \n\(networkingError.debugDescription)")
      return networkingError
    } else {
      return nil
    }
  }
  
}
