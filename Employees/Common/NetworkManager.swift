//
//  NetworkManager.swift
//  myFancyCars
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli Ma. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
  
  //shared instance
  static let sharedInstance = NetworkManager()
  
  let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
  var reachabilityStatus: NetworkStatus = .reachable
  
  func startNetworkReachabilityObserver() {
    
    reachabilityManager?.listener = { status in
      switch status {
      case .reachable(_), .unknown:
        self.reachabilityStatus = .reachable
      case .notReachable:
        self.reachabilityStatus = .notReachable
      }
    }
    
    // start listening
    reachabilityManager?.startListening()
  }
}
