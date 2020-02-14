//
//  Employee.swift
//  Employees
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import Foundation

enum EmployeeType: String, Decodable {
  case unknown
  case FULL_TIME
  case PART_TIME
  case CONTRACTOR
  
  var description: String {
    switch self {
      case .FULL_TIME:
        return "Full-time"
      case .PART_TIME:
        return "Part-time"
      case .CONTRACTOR:
        return "Contractor"
    default:
      return "Not classified"
    }
  }
}

struct Employee: Decodable {
  // The unique identifier for the employee. Represented as a UUID.
  let employeeID: String
  // The full name of the employee.
  var fullName: String
  // The phone number of the employee, sent as an unformatted string (eg, 5556661234).
  let phoneNumber: String?
  // The email address of the employee.
  let email: String
  // A short, tweet-length (~300 chars) string that the employee provided to describe themselves.
  let biography : String?
  // The URL of the employee’s small photo. Useful for list view.
  var photoSmall: String?
  // The URL of the employee’s full-size photo.
  let photoLarge: String?
  // The team they are on, represented as a human readable string.
  var team : String
  // enum (FULL_TIME, PART_TIME, CONTRACTOR) : YES : How the employee is classified.
  let employeeType: EmployeeType
  
  private enum CodingKeys: String, CodingKey {
    case employeeID = "uuid"
    case fullName = "full_name"
    case phoneNumber = "phone_number"
    case email = "email_address"
    case biography
    case photoSmall = "photo_url_small"
    case photoLarge = "photo_url_large"
    case team
    case employeeType = "employee_type"
  }
  
  init() {
    self.employeeID = "xxxx-xxxx"
    self.fullName = ""
    self.phoneNumber = nil
    self.email = ""
    self.biography = nil
    self.photoSmall = nil
    self.photoLarge = nil
    self.team = ""
    self.employeeType = .unknown
  }
  
  init(from decoder: Decoder) throws {
    let flatContainer = try decoder.container(keyedBy: CodingKeys.self)
    
    self.employeeID = try flatContainer.decode(String.self, forKey: .employeeID)
    self.fullName = try flatContainer.decode(String.self, forKey: .fullName)
    self.phoneNumber = try flatContainer.decode(String.self, forKey: .phoneNumber)
    self.email = try flatContainer.decode(String.self, forKey: .email)
    self.biography = try flatContainer.decode(String.self, forKey: .biography)
    self.photoSmall = try flatContainer.decode(String.self, forKey: .photoSmall)
    self.photoLarge = try flatContainer.decode(String.self, forKey: .photoLarge)
    self.team = try flatContainer.decode(String.self, forKey: .team)
    self.employeeType = EmployeeType.init(rawValue: try flatContainer.decode(String.self, forKey: .employeeType)) ?? .unknown
  }
}
