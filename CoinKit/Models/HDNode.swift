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
  case nodeError(String)
}

public struct HDNode {
  
  static let highestBit = 0x80000000
  
  public let keyPair: ECPair
  
  let chainCode: Data
  
  let depth: Int
  
  let index: Int
  
  let parentFingerprint: Data
  
  public var address: String {
    return keyPair.address
  }
  
  public var identifier: Data {
    return keyPair.publicKey.sha256.ripemd160
  }
  
  public var fingerprint: Data {
    return identifier[0 ..< 4]
  }
  
  public var isNeutered: Bool {
    return false
  }
  
  public init(seed: Data, network: Network = .bitcoin) throws {
    guard seed.count >= 16 else { throw HDNodeError.seedLength("Seed should be at least 128 bits") }
    guard seed.count <= 64 else { throw HDNodeError.seedLength("Seed should be at most 512 bits") }
    
    let key = "Bitcoin seed".data(using: .utf8)!
    let data = HMAC.sign(data: seed, algorithm: .sha512, key: key)
    let dataLeft = data[0 ..< 32]
    let dataRight = data[32 ..< data.count]
    
    let pair = try ECPair(privateKey: dataLeft, network: network)
    self.init(keyPair: pair, chainCode: dataRight, depth: 0, index: 0, parent: Data())
  }
  
  init(keyPair: ECPair, chainCode: Data, depth: Int, index: Int, parent: Data) {
    self.keyPair = keyPair
    self.chainCode = chainCode
    self.depth = depth
    self.index = index
    self.parentFingerprint = parent
  }
  
  public init(seedHex: String, network: Network = .bitcoin) throws {
    guard let seed = seedHex.hexadecimal() else { throw HDNodeError.seedInvalid }
    try self.init(seed: seed, network: network)
  }
  
  public init(mnemonic: Mnemonic) throws {
    try self.init(seed: mnemonic.seed())
  }
  
  public func derive(path: String) -> HDNode {
    return self
  }
  
  public func deriveHardened(_ index: Int) throws -> HDNode {
    return try derive(index + HDNode.highestBit)
  }
  
  public func derive(_ index: Int) throws -> HDNode {
    let isHardened = index >= HDNode.highestBit
    var data = Data(count: 1)
    if isHardened {
      guard !isNeutered else {
        throw HDNodeError.nodeError("Could not derive hardened child key")
      }
      
      // data = 0x00 || ser256(kpar) || ser32(index)
      data[0] = 0x00
      let buffer = keyPair.privateKey!
      data.append(buffer)
      data.append(String(format:"%2X", index).hexadecimal()!)
    } else {
      // data = serP(point(kpar)) || ser32(index)
      //      = serP(Kpar) || ser32(index)
      data = Data()
      let buffer = keyPair.privateKey!
      data.append(buffer)
      data.append(String(format:"%2X", index).hexadecimal()!)
    }
    
    let I =  HMAC.sign(data: data, algorithm: .sha512, key: chainCode)
    let IL = I[0 ..< 32]
    let IR = I[32 ..< I.count]
    
    let curve = Secp256k1()
    // In case parse256(IL) >= n, proceed with the next value for i
    if (!curve.check(key: IL)) {
      return try derive(index + 1)
    }

    // Private parent key -> private child key
    let derivedKeyPair: ECPair
    
    if !isNeutered {
      // ki = parse256(IL) + kpar (mod n)
      let pIL = BigUInt(IL)
      let ki = (pIL + BigUInt(self.keyPair.privateKey!)) % curve.n

      // In case ki == 0, proceed with the next value for i
      if (ki.signum() == 0) {
        return try self.derive(index + 1)
      }
      
      let dKi = ki.serialize()
      derivedKeyPair = try ECPair(privateKey: dKi, network: keyPair.network)
      
      // Public parent key -> public child key
    } else {
      derivedKeyPair = self.keyPair
      /*
      // Ki = point(parse256(IL)) + Kpar
      //    = G*IL + Kpar
      let ki = curve.G.multiply(pIL).add(this.keyPair.Q)
      
      // In case Ki is the point at infinity, proceed with the next value for i
      if (curve.isInfinity(Ki)) {
        return this.derive(index + 1)
      }
      
      derivedKeyPair = new ECPair(null, Ki, {
        network: this.keyPair.network
      })
       */
    }
    
    let hd = HDNode(keyPair: derivedKeyPair, chainCode: IR,
                    depth: depth + 1, index: index,
                    parent: fingerprint[0 ..< 4])
    return hd
  }
}
