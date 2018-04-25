//
//  SmsgPong.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct SmsgPong: Command {
    
    let name: String = "smsgPong"
    
    init() {
      
    }
    
    func encode() -> Data {
      return Data()
    }
  }
}

