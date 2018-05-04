//
//  Message.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct Message {
  
  public let type: String
  
  public let length: UInt32
  
  public let value: Data
  
  public let data: Data
  
  public let checkSum: Data
  
  init?(data: Data, magicNumber: UInt32) {
    do {
      let reader = DataReader(data: data)
      
      let _ = try reader.read(bytes: 4)
      let typeChunk = try reader.read(bytes: 12)
      let length: UInt32 = try reader.read(endian: .little)
      let checkSum: Data = try reader.read(bytes: 4)
      
      guard data.count - 24 == length else { return nil }
      let value: Data = try reader.read(bytes: UInt(length))
      
      guard let typeD = typeChunk.split(separator: 0).first,
        let type = String(data: typeD, encoding: .ascii) else { return nil }
      
      self.type = type
      self.value = value
      self.data = data
      self.length = length
      self.checkSum = checkSum
    } catch _ {
      return nil
    }
  }
}
