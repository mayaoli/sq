//
//  Extensions.swift
//  Employees
//
//  Created by RBC on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {

  func imageFromUrl(_ urlString: String, placeHolder: UIImage? = #imageLiteral(resourceName: "no_image"), completion: ((_ success: Bool) -> Void)? = nil) {
    if !urlString.isEmpty, let url = URL(string: urlString) {
      self.sd_setImage(with: url, placeholderImage: placeHolder, options: SDWebImageOptions(), completed: { (_, error, _, _) in
        if let block = completion {
          block(error == nil)
        }
      })
    } else {
      self.image = placeHolder
    }
  }
  
}

/// decoder
public struct CKey: CodingKey {
  public let stringValue: String
  public init?(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = nil
  }
  
  public let intValue: Int?
  public init?(intValue: Int) {
    return nil
  }
}

public extension JSONDecoder {
  
  private static let nestedModelKeyPathCodingUserInfoKey = CodingUserInfoKey(rawValue: "nested_model_keypath")!
  
  private struct ModelResponse<TargetModel: Decodable>: Decodable {
    let model: TargetModel
    
    init(from decoder: Decoder) throws {
      // Split nested paths with '.'
      var keyPaths = (decoder.userInfo[JSONDecoder.nestedModelKeyPathCodingUserInfoKey]! as! String).split(separator: ".")
      
      // Get last key to extract in the end
      let lastKey = String(keyPaths.popLast()!)
      
      // Loop getting container until reach final one
      var targetContainer = try decoder.container(keyedBy: CKey.self)
      for k in keyPaths {
        let key = CKey(stringValue: String(k))!
        targetContainer = try targetContainer.nestedContainer(keyedBy: CKey.self, forKey: key)
      }
      model = try targetContainer.decode(TargetModel.self, forKey: CKey(stringValue: lastKey)!)
    }
  }
  
  /// Decodes a model T from json data with the given keypath.
  func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
    self.userInfo[JSONDecoder.nestedModelKeyPathCodingUserInfoKey] = keyPath
    return try self.decode(ModelResponse<T>.self, from: data).model
  }
  
}

extension KeyedDecodingContainer {
  
  func decode<T>(_ type: T.Type, forNestedKey key: CKey) throws -> T where T : Decodable {
    var keyPaths = key.stringValue.split(separator: ".")
    
    guard keyPaths.count > 1 else {
      return try self.decodeIfPresent(type.self, forKey: KeyedDecodingContainer<K>.Key(stringValue: key.stringValue)!)!
    }
    
    let lastKey = String(keyPaths.popLast()!)
    
    var targetContainer = self
    
    for k in keyPaths {
      let key = CKey(stringValue: String(k))! as! K
      targetContainer = try targetContainer.nestedContainer(keyedBy: K.self , forKey: key)
    }
    return try targetContainer.decode(type.self, forKey: CKey(stringValue: lastKey) as! K)
  }
  
}

// Observe for decodable objects
class Observable<ObservedType>: Decodable where ObservedType: Decodable {
  
  typealias Listener =  (ObservedType) -> ()
  
  var listeners = [Listener]()
  
  var value: ObservedType {
    didSet {
      listeners.forEach { li in
        li(value)
      }
    }
  }
  
  func bind(listener: @escaping Listener) {
    self.listeners.append(listener)
    if let li = self.listeners.last {
      li(self.value)
    }
  }
  
  init(_ value: ObservedType) {
    self.value = value
  }
  
  private enum CodingKeys: CodingKey {
    case value
  }
  
}
