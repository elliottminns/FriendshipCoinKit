//
//  Pushdata.swift
//  CoinKit
//
//  Created by Elliott Minns on 21/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct Pushdata {
  
  enum Error: Swift.Error {
    case unexpectedOpcode
  }
  
  static func encode(data: Data) throws -> Data {
    let number = data.count
    let size = encodingLength(data.count)
    var encoded = Data()
    if (size == 1) {
      encoded.append(UInt8(number))
    } else if (size == 2) {
      encoded.append(OPCodes.OP_PUSHDATA1.value)
      encoded.append(UInt8(number))
    } else if (size == 3) {
      encoded.append(OPCodes.OP_PUSHDATA2.value)
      encoded.append(bytesFrom: UInt16(number), endian: .little)
    } else {
      encoded.append(OPCodes.OP_PUSHDATA4.value)
      encoded.append(bytesFrom: UInt32(number), endian: .little)
    }
    
    return encoded
  }
  
  static func encodingLength(_ i: Int) -> Int {
    return i < OPCodes.OP_PUSHDATA1.value ? 1
      : i <= 0xff ? 2
      : i <= 0xffff ? 3
      : 5
  }
  
  static func decode(data: Data) throws -> (number: UInt, size: UInt8, opcode: UInt8)? {
    guard let opcode = data.first else { return nil }
    
    let number: UInt
    let size: UInt8
    
    if opcode < OPCodes.OP_PUSHDATA1.value {
      number = UInt(opcode)
      size = 1
    } else if opcode == OPCodes.OP_PUSHDATA1.value {
      guard data.count >= 2 else { return nil }
      number = UInt(data[data.startIndex.advanced(by: 1)])
      size = 2
    } else if opcode == OPCodes.OP_PUSHDATA2.value {
      guard data.count >= 4 else { return nil }
      let reader = DataReader(data: data)
      let value: UInt32 = try reader.read(endian: .little)
      number = UInt(value)
      size = 3
    } else {
      guard data.count >= 5 else { return nil }
      guard opcode != OPCodes.OP_PUSHDATA4.value else { throw Error.unexpectedOpcode }

      let reader = DataReader(data: data[data.startIndex ..< data.endIndex])
      let value: UInt32 = try reader.read(endian: .little)
      number = UInt(value)
      size = 5
    }
    
    return (number: number, size: size, opcode: opcode)
  }
}
