//
//  EmployeeServices.swift
//  myFancyCars
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli Ma. All rights reserved.
//

import Foundation

class EmployeeServices: BaseServices {
  
  var forTest: UnitTestType = .none

  func getList(completion: @escaping (_ employees: [Employee], _ error: NetworkingError?) -> Void) -> URLSessionTask? {
    var urlString : String
    
    switch forTest {
    case .empty:
      urlString = "\(Constants.BASE_URL)/employees_empty.json"
    case .failed:
      urlString = "\(Constants.BASE_URL)/employees_malformed.json"
    default:
      urlString = "\(Constants.BASE_URL)/employees.json"
    }
    
    guard let url = URL(string: urlString) else {
      completion([], .unknown)
      return nil
    }
    
    return get(url: url) { (response, data, error) in
      guard error == nil else {
        completion([], error)
        return
      }
      
      guard data?.data != nil, data?.type == .json else {
        completion([], .responseValidationFailed)
        return
      }
      
      print(data?.json ?? "")
      
      do {
        let jDecoder = JSONDecoder()
        let list = try jDecoder.decode([Employee].self, from: data!.data, keyPath: "employees")
        completion(list, nil)
      } catch _ {
        completion([], .responseValidationFailed)
      }
      
    }
  }
    
}
