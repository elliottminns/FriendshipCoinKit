//
//  ECPair.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import Security
import CommonCrypto
import BigInt

enum ECPairError: Error {
  case invalidPrivateKey
}

public struct ECPair {
  
  let privateKey: Data
  
  let network: Network
  
  public var address: String {
    let sha = publicKey.sha256
    let hash = Ripemd160.hash(message: sha)
    let version = network.version
    let total = Data([version]) + hash
    return total.base58CheckEncodedString
  }
  
  public var publicKey: Data {
    let secp256k1 = Secp256k1()
    return try! secp256k1.publicKey(from: privateKey)
  }
  
  init(privateKey: Data, network: Network) throws {
    let secp256k1 = Secp256k1()
    
    let big = BigUInt(privateKey)
    guard big > 0 else {
      throw ECPairError.invalidPrivateKey
    }
    
    guard secp256k1.check(key: privateKey) else {
      throw ECPairError.invalidPrivateKey
    }
    
    self.privateKey = privateKey
    self.network = network
  }
}
