//
//  EmployeeViewModel.swift
//  Employees
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import Foundation

class EmployeeViewModel {
  var employeeList: Observable<[Employee]> = Observable([])
  
  func loading() {
    let emptyEmployee = Employee()
    
    self.employeeList.value = [emptyEmployee, emptyEmployee, emptyEmployee, emptyEmployee]
  }
  
  func fetchData(completion: @escaping ((NetworkingError?) -> Void)) {
    let service = EmployeeServices()
    
    func completionWithError(_ error: NetworkingError, _ completion: (NetworkingError?) -> Void) -> Void  {
      var empty = Employee()
      empty.fullName = "Full name"
      empty.team = "team"
      empty.photoSmall = ""
      self.employeeList.value = [empty]
      completion(error)
    }
    
    _ = service.getList { (list, error) in
      guard error == nil else {
        completionWithError(error!, completion)
        return
      }
      
      guard list.count > 0 else {
        completionWithError(.unknown, completion)
        return
      }
      
      self.employeeList.value = list.sorted(by: { $0.fullName < $1.fullName })
      
      completion(nil)
    }
    
  }
  
  //TODO: check large whether has been cached by UID
  func cacheImages() {
    guard self.employeeList.value.count > 0 else {
      return
    }
    
    var imagesData: [String:Data?] = [:]
    
    DispatchQueue(label: "loadLargeImages", attributes: []).async {
      self.employeeList.value.forEach { ep in
        if let urlString = ep.photoLarge, let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
          imagesData[ep.employeeID] = data
        } else {
          imagesData[ep.employeeID] = nil
        }
      }
      
      StorageManager.setObject(arrayToSave: imagesData as [String : Any], path: Constants.STORAGE_PATH)
    }
    
  }
  
  func getEmployeeNumbers() -> Int {
    return self.employeeList.value.count
  }
  
  func getEmployee(atIndex: Int) -> Employee? {
    guard atIndex >= 0, atIndex < self.employeeList.value.count else {
      return nil
    }
    return self.employeeList.value[atIndex]
  }
}
