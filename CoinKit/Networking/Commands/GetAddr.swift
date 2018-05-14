//
//  GetAddr.swift
//  CoinKit
//
//  Created by Elliott Minns on 04/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct GetAddr: Command {
    
    let name: String = "getaddr"
    
    func encode() -> Data {
      return Data()
    }
  }
}
