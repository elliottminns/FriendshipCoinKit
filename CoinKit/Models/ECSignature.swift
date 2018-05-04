//
//  ECSignature.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension BInt {
  public init?(data: Data) {
    self.init(data.hexEncodedString(), radix: 16)
  }
  
  var data: Data {
    return asString(radix: 16).hexadecimal() ?? Data()
  }
}

struct ECSignature {
  
  enum Error: Swift.Error {
    case invalidHashType
  }
  
  let data: Data
  
  let r: BInt
  
  let s: BInt
  
  init(data: Data) {
    self.data = data
    self.r = BInt(data: Data(data[data.startIndex + 4 ..< data.startIndex + 36])) ?? BInt(0)
    self.s = BInt(data: Data(data[data.startIndex + 38 ..< data.startIndex + 70])) ?? BInt(0)
  }
  
  func toScriptSignature(hashType: UInt8) throws -> Data {
    let hashTypeMod = hashType & ~0x80
    guard hashTypeMod > 0 && hashTypeMod < 4 else { throw Error.invalidHashType }
    
    let buffer = Data([hashTypeMod])
    
    return data + buffer //try //toDER() + buffer
  }
  
  func toDER() throws -> Data {
    return try Bip66.encode(r: r.data, s: s.data)
  }
}
