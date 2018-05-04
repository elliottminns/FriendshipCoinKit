//
//  GetData.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

enum InventoryType: UInt8 {
  case error = 0
  case msgTx
  case msgBlock
  case msgFilteredBlock
}

public struct InventoryItem {
  let type: InventoryType
  
  let hash: Data
  
  init(type: InventoryType, hash: String) {
    self.init(type: type, hash: hash.hexadecimal() ?? Data())
  }
  
  init(type: InventoryType, hash: Data) {
    self.hash = hash
    self.type = type
    
  }
}

extension CommandType {
  
  struct GetData: Command {
    
    let name: String = "getdata"
    
    let inventory: [InventoryItem]
    
    init(inventory: [InventoryItem]) {
     self.inventory = inventory
    }
    
    func encode() -> Data {
      let length = inventory.count
      var data = Data()
      data.append(variable: length, endian: .little)
      data.append(inventory.reduce(Data()) { (data, item) -> Data in
        var data = data
        data.append(bytesFrom: UInt32(item.type.rawValue), endian: .little)
        data.append(item.hash)
        return data
      })
      
      return data
    }
  }
}
