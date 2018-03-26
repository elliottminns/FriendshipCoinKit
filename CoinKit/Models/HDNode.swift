//
//  HDNode.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import Crypto
import BigInt

enum HDNodeError: Error {
  case seedLength(String)
  case seedInvalid
}

public struct HDNode {
  
  let keyPair: ECPair
  
  let chainCode: Data
  
  let depth: Int
  let index: Int
  let parentFingerprint: Int
  
  public init(seed: Data, network: Network = .bitcoin) throws {
    guard seed.count > 16 else { throw HDNodeError.seedLength("Seed should be at least 128 bits") }
    guard seed.count < 64 else { throw HDNodeError.seedLength("Seed should be at most 512 bits") }
    
    let key = "Bitcoin seed".data(using: .utf8)!
    let data = HMAC.sign(data: seed, algorithm: .sha512, key: key)
    let dataLeft = data[0 ..< 32]
    let dataRight = data[32 ..< data.count]
    /*guard let priv = BigUInt(dataLeft.hexEncodedString(), radix: 16) else {
      throw HDNodeError.seedInvalid
    }*/
    let pair = try ECPair(privateKey: dataLeft, network: network)
    self.init(keyPair: pair, chainCode: dataRight)
  }
  
  init(keyPair: ECPair, chainCode: Data) {
    self.keyPair = keyPair
    self.chainCode = chainCode
    self.depth = 0
    self.index = 0
    self.parentFingerprint = 0x00000000
  }
  
  public init(seedHex: String, network: Network = .bitcoin) throws {
    guard let seed = seedHex.hexadecimal() else { throw HDNodeError.seedInvalid }
    try self.init(seed: seed, network: network)
  }
  
  /*
  public init(base58: String) {
    
  }*/
  
  public init(mnemonic: Mnemonic) throws {
    try self.init(seed: mnemonic.seed())
  }
  
  func derive(path: String) -> HDNode {
    return self
  }
  
  func deriveHardened(_ index: Int) -> HDNode {
    return self
  }
  
  func derive(_ index: Int) -> HDNode {
    return self
  }
}
