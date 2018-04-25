//
//  GetHeader.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct GetHeaders: Command {
    
    let name: String = "getheaders"
    
    let version: UInt32
    
    let locators: [Data]
    
    let stopHash: Data?
    
    func encode() -> Data {
     
      var data = Data()
      data.append(bytesFrom: version, endian: .big)
      data.append(variable: locators.count, endian: .little)
      data.append(locators.reduce(Data()) { $0 + $1 })
      if let stopHash = stopHash {
        data.append(stopHash)
      } else {
        data.append(contentsOf: [UInt8].init(repeating: 0, count: 32))
      }
      
      return data
    }
  }
}
