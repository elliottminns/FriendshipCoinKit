//
//  BitcoinTxInput.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension BitcoinTransaction {
  enum InputType {
    case prevOut
  }
  
  public struct Input: TransactionInput {
    
    let hash: Data
    
    let index: UInt32
    
    let script: Data
    
    let sequence: UInt32
    
    let witness: [Data]
    
    let type: InputType = .prevOut
    
    init(hex: String, index: UInt32, scriptHex: String) {
      let data = hex.hexadecimal() ?? Data()
      let script = scriptHex.hexadecimal() ?? Data()
      self.init(hash: data, index: index, script: script)
    }
    
    init(hash: Data, index: UInt32, script: Data = Data(), sequence: UInt32? = nil, witness: [Data] = []) {
      self.hash = hash
      self.index = index
      self.script = script
      self.sequence = sequence ?? 4294967295
      self.witness = witness
    }
    
    func build() {
      
    }
    
    func add(witness: [Data]) -> Input {
      return Input(hash: hash, index: index, script: script, sequence: sequence, witness: witness)
    }
  }
}
