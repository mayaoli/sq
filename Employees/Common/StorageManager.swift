//
//  StorageManager.swift
//  myFancyCars
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli Ma. All rights reserved.
//

import Foundation

// Could use other mechanism, like Core Data, SqlLite, event NSUserDefaults (small)
class StorageManager {
  class private func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  class func setObject(arrayToSave: [String: Any], path: String) {
    let fullPath = documentsDirectory().appendingPathComponent(path)
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: arrayToSave, requiringSecureCoding: false)
      try data.write(to: fullPath)
    } catch {
      print("Failed to save object ...")
    }
  }
  
  class func getObject(path: String) -> [String: Any]? {
    let fullPath = documentsDirectory().appendingPathComponent(path)
    if let nsData = NSData(contentsOf: fullPath) {
        do {
            let data = Data(referencing:nsData)
            if let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any] {
              return result
            }
        } catch {
            print("Couldn't read object ...")
            return nil
        }
    }
    return nil
  }
}
