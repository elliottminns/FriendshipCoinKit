//
//  Script.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class Script {
  
  let data: Data
  
  var isCanonicalSignature: Bool {
    guard let last = data.last, isDefinedHashType(hashType: last) else {
      return false
    }
    
    return data.checkBip66()
  }
  
  fileprivate func isDefinedHashType(hashType: UInt8) -> Bool {
    let hashTypeMod = hashType & ~0x80
    return hashTypeMod > 0x00 && hashTypeMod < 0x04
  }
  
  var isCanonicalPubKey: Bool {
    guard data.count >= 33, let first = data.first else { return false }
    
    switch first {
    case 0x02, 0x03: return data.count == 33
    case 0x04: return data.count == 65
    default: return false
    }
  }
  
  init(data: Data) {
    self.data = data
  }
  
  static func isPushOnly(chunks: [Data]) -> Bool {
    return chunks.reduce(true) { isPushOnly(value: $1) && $0 }
  }
  
  static func isPushOnly(value: Data) -> Bool {
    guard let first = value.first, value.count == 1 else { return false }
    return first == OPCodes.OP_0.value ||
      (first > OPCodes.OP_1.value && first <= OPCodes.OP_16.value) ||
      first == OPCodes.OP_1NEGATE.value
  }
  
  static func compile(chunks: Array<Data>) -> Data {
    return chunks.reduce(Data(), { (data, chunk) -> Data in
      if chunk.count <= 1 {
        return data + chunk
      } else {
        if let opcode = asMinimalOP(data: chunk) {
          return data + Data(bytes: [opcode])
        } else {
          let encoded = (try? Pushdata.encode(data: chunk)) ?? Data()
          return data + encoded + chunk
        }
      }
    })
  }
  
  static func decompile(data: Data) throws -> [Data] {
    var chunks: [Data] = []
    var i: Int = 0
    while i < data.count {
      let opcode = data[i]
      if opcode > OPCodes.OP_0.value && opcode <= OPCodes.OP_PUSHDATA4.value {
        guard let d = try Pushdata.decode(data: data[data.startIndex + i ..< data.endIndex]) else { return [] }
        
        i = i + Int(d.size)
        
        guard (i + Int(d.number)) <= data.count else { return [] }
        
        let start = data.startIndex + Int(i)
        let end = start + Int(d.number)
        let slice = Data(data[start ..< end])
        i = i + Int(d.number)
        
        if let op = asMinimalOP(data: slice) {
          chunks.append(Data(bytes: [op]))
        } else {
          chunks.append(slice)
        }
      } else {
        chunks.append(Data(bytes: [opcode]))
        i = i + 1
      }
    }
    
    return chunks
  }

  fileprivate static func asMinimalOP(data: Data) -> UInt8? {
    if data.count == 0 { return OPCodes.OP_0.value }
    if data.count != 1 { return nil }
    if data[data.startIndex] >= 1 && data[data.startIndex] <= 16 {
      return OPCodes.OP_RESERVED.value + data[data.startIndex]
    }
    if data[data.startIndex] == 0x81 { return OPCodes.OP_1NEGATE.value }
    return nil
  }
}
