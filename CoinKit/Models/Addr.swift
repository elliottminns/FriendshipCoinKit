//
//  Addr.swift
//  CoinKit
//
//  Created by Elliott Minns on 04/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct Addr: Timestamped {
  let timestamp: UInt32
  
  let version: Data
  
  let address: String
  
  let port: UInt16
  
  init?(reader: DataReader) throws {
    self.timestamp = try reader.read(endian: .little)
    self.version = try reader.read(bytes: 8)
    let addressData = try reader.read(bytes: 16)
    if addressData[10 ..< 12].bytes == [0xff, 0xff] {
      self.address = Data(addressData[12 ..< 16].reversed()).map {
        return "\($0)"
      }.joined(separator: ".")
    } else {
      return nil
    }
    self.port = try reader.read(endian: .little)
  }
}
