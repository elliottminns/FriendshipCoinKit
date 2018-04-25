//
//  Command.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol Command {
  var name: String { get }
  
  func encode() -> Data
}

extension Command {
  func header(magic: UInt32) -> Data {
    let encoded = self.encode()
    let length = encoded.count

    var data = Data()

    data.append(bytesFrom: magic, endian: .little)
    data.append(name.data(using: .ascii)!)
    let zeros = 16 - data.count
    data.append(contentsOf: [UInt8](repeating: 0, count: zeros))
    data.append(bytesFrom: UInt32(length), endian: .little)
    data.append(checksum(data: encoded))
    
    return data
  }
  
  func checksum(data: Data) -> Data {
    return Data(data.sha256.sha256[0 ..< 4])
  }
  
}
