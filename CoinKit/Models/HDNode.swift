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
  case invalidBase58
  case unknownNetwork
}

public struct HDNode {
  
  static let highestBit = 0x80000000
  
  public let keyPair: ECPair
  
  let chainCode: Data
  
  let depth: UInt8
  
  let index: UInt32
  
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
    return keyPair.privateKey == nil
  }
  
  public init(seed: Data, network: Network = NetworkType.bitcoin) throws {
    guard seed.count >= 16 else { throw HDNodeError.seedLength("Seed should be at least 128 bits") }
    guard seed.count <= 64 else { throw HDNodeError.seedLength("Seed should be at most 512 bits") }
    
    let key = "Bitcoin seed".data(using: .utf8)!
    let data = HMAC.sign(data: seed, algorithm: .sha512, key: key)
    let dataLeft = data[0 ..< 32]
    let dataRight = data[32 ..< data.count]
    
    let pair = try ECPair(privateKey: dataLeft, network: network)
    self.init(keyPair: pair, chainCode: dataRight, depth: 0, index: 0, parent: Data())
  }
  
  public init(seedHex: String, network: Network = NetworkType.bitcoin) throws {
    guard let seed = seedHex.hexadecimal() else { throw HDNodeError.seedInvalid }
    try self.init(seed: seed, network: network)
  }
  
  public init(mnemonic: Mnemonic) throws {
    try self.init(seed: mnemonic.seed())
  }
  
  public init(base58: String, network: Network) throws {
    try self.init(base58: base58, networks: [network])
  }
  
  public init(base58: String, networks: [Network]) throws {
    guard let buffer = base58.base58CheckDecodedData,
      buffer.count == 78 else {
      throw HDNodeError.invalidBase58
    }
    
    let version = UInt32(data: buffer[buffer.startIndex ..< buffer.startIndex + 4])

    guard let network = (networks.filter {
      return version == $0.bip32.private || version == $0.bip32.public
    }.first) else { throw HDNodeError.unknownNetwork }
    
    let depth = buffer[buffer.startIndex + 4]
    let parentFingerprint = buffer[5 ..< 9]
    if depth == 0 && parentFingerprint.bytes != [0, 0, 0, 0] {
      throw HDNodeError.invalidBase58
    }
    
    let index = UInt32(data: buffer[9 ..< 13])
    if depth == 0 && index != 0 { throw HDNodeError.invalidBase58 }
    let chainCode = buffer[13 ..< 45]
    
    let keyPair: ECPair
    
    if version == network.bip32.private {
      if buffer[45] != 0x00 { throw HDNodeError.invalidBase58 }
      let privateKey = buffer[46 ..< 78]
      keyPair = try ECPair(privateKey: privateKey, network: network, compressed: true)
    } else {
      let key = buffer[45 ..< 78]
      keyPair = try ECPair(publicKey: key, network: network, compressed: true)
    }
    
    self.init(keyPair: keyPair, chainCode: chainCode, depth: depth, index: index, parent: parentFingerprint)
  }
  
  init(keyPair: ECPair, chainCode: Data, depth: UInt8, index: UInt32, parent: Data) {
    self.keyPair = keyPair
    self.chainCode = chainCode
    self.depth = depth
    self.index = index
    self.parentFingerprint = parent
  }
  
  public func toBase58(isPrivate: Bool) throws -> String {
    let network = keyPair.network
    let version = isNeutered || !isPrivate ? network.bip32.public : network.bip32.private
    let versionBytes = version.bytes
    let depthBytes = [UInt8(depth)]
    let parentBytes = parentFingerprint.count > 0 ? parentFingerprint.bytes : [0,0,0,0]
    let indexBytes = UInt32(index).bytes
    let chainCodeBytes = chainCode.bytes
    let keyBytes: [UInt8]
    
    if let privateKey = keyPair.privateKey, isPrivate {
      keyBytes = [0] + privateKey.bytes
    } else {
      keyBytes = keyPair.publicKey.bytes
    }
    
    let buffer = versionBytes + depthBytes + parentBytes + indexBytes +
      chainCodeBytes + keyBytes
    
    return buffer.base58CheckEncodedString
  }
  
  public func derive(path: String) throws -> HDNode {
    let splitPath = path.components(separatedBy: "/")
    
    let comps: [String]
    if splitPath.first == "m" {
      guard parentFingerprint.count == 0 || parentFingerprint.bytes == [0, 0, 0, 0] else {
        throw HDNodeError.nodeError("Not a master node")
      }
      comps = Array(splitPath[1 ..< splitPath.endIndex])
    } else {
      comps = splitPath
    }
    
    return try comps.reduce(self) { (node, indexStr) throws -> HDNode in
      if indexStr.last == "'" {
        let start = indexStr.startIndex
        let end = indexStr.index(before: indexStr.endIndex)
        guard let index = Int(indexStr[start ..< end]) else {
          throw HDNodeError.nodeError("Incorrect path number")
        }
        return try node.deriveHardened(index)
      } else {
        guard let index = Int(indexStr) else  {
          throw HDNodeError.nodeError("Incorrect path number")
        }
        return try node.derive(index)
      }
    }
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
      
      data[0] = 0x00
      let buffer = keyPair.privateKey!
      data.append(buffer)
      data.append(contentsOf: UInt32(index).bytes)
    } else {
      data = Data()
      let buffer = keyPair.publicKey
      data.append(buffer)
      data.append(contentsOf: UInt32(index).bytes)
    }
    
    let I = HMAC.sign(data: data, algorithm: .sha512, key: chainCode)
    let IL = I[0 ..< 32]
    let IR = I[32 ..< I.count]
    
    let curve = Secp256k1()
    if (!curve.check(key: IL)) {
      return try derive(index + 1)
    }

    let derivedKeyPair: ECPair
    if !isNeutered {
      let pIL = BigUInt(IL)
      let ki = (pIL + BigUInt(self.keyPair.privateKey!)) % curve.n

      if (ki.signum() == 0) {
        return try self.derive(index + 1)
      }
      
      let dKi = ki.serialize()
      derivedKeyPair = try ECPair(privateKey: dKi, network: keyPair.network)
    } else {
      let secp256k1 = Secp256k1()
      do {
        let ki = try secp256k1.add(publicKey: keyPair.publicKey, with: IL)
        derivedKeyPair = try ECPair(publicKey: ki, network: keyPair.network)
      } catch let error {
        if let err = error as? Secp256k1Error,
          case .invalidTweak = err {
          return try derive(index + 1)
        } else {
          throw error
        }
      }
    }
    
    let hd = HDNode(keyPair: derivedKeyPair, chainCode: IR,
                    depth: depth + 1, index: UInt32(index),
                    parent: fingerprint[0 ..< 4])
    return hd
  }
}
