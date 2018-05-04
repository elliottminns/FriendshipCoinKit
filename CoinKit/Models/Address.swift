//
//  Address.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct Address {
  
  enum Error: Swift.Error {
    case incorrectAddress
    case noMatchingScript
  }
  
  public let network: Network
  
  public let address: String
  
  init(address: String, network: Network) {
    self.address = address
    self.network = network
  }
  
  init?(outputScript: Data, network: Network) {
    self.network = network
    if TemplateType.pubKeyHash.output.check(data: outputScript) {
      let data = Data([network.version]) + Data(outputScript[3 ..< 23])
      self.address = data.base58CheckEncodedString
    } else if TemplateType.scriptHash.output.check(data: outputScript) {
      let data = Data([network.script]) + Data(outputScript[2 ..< 22])
      self.address = data.base58CheckEncodedString
    } else {
      return nil
    }
  }
  
  init?(inputScript: Data, network: Network) {
    self.network = network
    
    do {
      if try TemplateType.scriptHash.input.check(data: inputScript) {
        return nil
      } else if try TemplateType.pubKeyHash.input.check(data: inputScript) {
        let chunks = try Script.decompile(data: inputScript)
        let last = chunks[1]
        self.address = (Data([network.version]) + last.hash160).base58CheckEncodedString
      } else {
        return nil
      }
      
    } catch _ {
      return nil
    }
  }
  
  func matchesScript(script: Data) -> Bool {
    guard let data = try? Script.decompile(data: script) else { return false }
    if VersionTemplate().output.check(data: data) {
      return true
    } else if ScriptTemplate().output.check(data: data) {
      return true
    } else {
      return false
    }
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
