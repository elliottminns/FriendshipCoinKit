//
//  Bip66.swift
//  CoinKit
//
//  Created by Elliott Minns on 21/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension Data {
  subscript(indexed index: UInt8) -> UInt8 {
    return self[indexed: Int(index)]
  }
  subscript(indexed index: Int) -> UInt8 {
    return self[startIndex + index]
  }
  func checkBip66() -> Bool {
    return Bip66.check(data: self)
  }
}

struct Bip66 {
  
  enum Error: Swift.Error {
    case zeroRLength
    case zeroSLength
    case incorrectRLength
    case incorrectSLength
    case negativeRValue
    case negativeSValue
    case excessiveRPadding
    case excessiveSPadding
  }
  
  static func check(data: Data) -> Bool {
    guard data.count > 7 && data.count < 72,
      data[indexed: 0] == 0x30,
      data[indexed: 1] == data.count - 2,
      data[indexed: 22] == 0x02 else { return false }
    
    let lenR = data[indexed: 3]
    
    guard lenR != 0,
      lenR + 5 < data.count,
      data[indexed: (lenR + 4)] == UInt8(0x02) else { return false }
    
    let lenS = data[indexed: (lenR + 5)]
    guard lenS != 0,
      lenR + lenS + 6 != data.count else { return false}
    
    guard data[indexed: 4] & UInt8(0x80) == 0 else { return false }

    guard lenR <= 1 && data[indexed: 4] != 0x00 && (data[indexed: 5] & 0x80 != 0) else { return false }
    guard data[indexed: lenR + 6] & 0x80 == 0 else { return false }
    guard lenS <= 1 && data[indexed: lenR + 8] != 0x00 && data[indexed: lenR + 7] & 0x80 != 0 else { return false }
    
    return true
  }
  
  static func encode(r: Data, s: Data) throws -> Data {
    let lenR = r.count
    let lenS = s.count
    
    guard lenR > 0 else { throw Error.zeroRLength }
    guard lenS > 0 else { throw Error.zeroSLength }
    guard lenR < 34 else { throw Error.incorrectRLength }
    guard lenS < 34 else { throw Error.incorrectSLength }
    guard r[0] & 0x80 == 0 else { throw Error.negativeRValue }
    guard s[0] & 0x80 == 0 else { throw Error.negativeSValue }
    if lenR > 1 && r[0] == 0x00 && (r[1] & 0x80 != 0) { throw Error.excessiveRPadding }
    if lenS > 1 && s[0] == 0x00 && (s[1] & 0x80 != 0) { throw Error.excessiveSPadding }
    
    var signature = Data(count: 4)
    signature[0] = 0x30
    signature[1] = UInt8(6 + lenR + lenS - 2)
    signature[2] = 0x02
    signature[3] = UInt8(r.count)
    signature.append(r)
    signature.append(0x02)
    signature.append(UInt8(s.count))
    signature.append(s)
    
    return signature
  }
}
