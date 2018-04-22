//
//  Address.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct Address {
  
  enum Error: Swift.Error {
    case incorrectAddress
    case noMatchingScript
  }
  
  let network: Network
  
  let address: String
  
  init(address: String, network: Network) {
    self.address = address
    self.network = network
  }
  
  func toOutputScript() throws -> Data {
    guard let payload = address.base58CheckDecodedData,
      let version = payload.first else {
      throw Error.incorrectAddress
    }
    
    let hash = Data(payload[1 ..< payload.endIndex])
    
    if version == network.version {
      return try VersionTemplate().output.encode(data: hash)
    } else if version == network.script {
      return try ScriptTemplate().output.encode(data: hash)
    } else {
      throw Error.noMatchingScript
    }
  }
  
}
