//
//  Data+Write.swift
//  CoinKit
//
//  Created by Elliott Minns on 17/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public extension Data {
  mutating func append(bool: Bool) {
    let value: UInt8 = bool ? 1 : 0
    append(bytesFrom: value, endian: .little)
  }
  
  mutating func append<T: FixedWidthInteger>(bytesFrom number: T, endian: Endian) {
    let bytes = endian == .big ? number.bytes : number.bytes.reversed()
    self.append(contentsOf: bytes)
  }
  
  mutating func append(variable number: Int, endian: Endian) {
    self.append(variable: UInt(number), endian: endian)
  }
  
  mutating func append(variable number: UInt, endian: Endian) {
    if number < 0xfd {
      append(bytesFrom: UInt8(number), endian: endian)
    } else if (number <= 0xffff) {
      append(bytesFrom: UInt8(0xfd), endian: endian)
      append(bytesFrom: UInt16(number), endian: endian)
    } else if (number <= 0xffffffff) {
      append(bytesFrom: UInt8(0xfe), endian: endian)
      append(bytesFrom: UInt32(number), endian: endian)
    } else {
      append(bytesFrom: UInt8(0xff), endian: endian)
      append(bytesFrom: UInt64(number), endian: endian)
    }
  }
  
  mutating func append(variable data: Data, endian: Endian) {
    append(variable: data.count, endian: endian)
    append(data)
  }
}
