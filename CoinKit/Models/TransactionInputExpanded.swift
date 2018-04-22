//
//  TransactionInputExpanded.swift
//  CoinKit
//
//  Created by Elliott Minns on 21/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension Transaction.Input {
  struct Expanded {
    
    let redeemScript: Data?
    
    let redeemScriptType: ScriptType
    
    let prevOutScript: Data?
    
    let prevOutType: ScriptType
    
    var publicKeys: [Data]
    
    var signatures: [Data]
    
    let signType: ScriptType
    
    let signScript: Data?
    
    let witness: Bool
    
    var canSign: Bool {
      return signScript != nil &&
        publicKeys.count > 0 &&
        signatures.count == publicKeys.count
    }
    
    init(publicKeys: [Data], signatures: [Data], signScript: Data, signType: ScriptType, prevOutType: ScriptType, prevOutScript: Data, witness: Bool) {
      self.publicKeys = publicKeys
      self.signatures = signatures
      self.signScript = signScript
      self.signType = signType
      self.prevOutType = prevOutType
      self.prevOutScript = prevOutScript
      self.witness = witness
      self.redeemScript = nil
      self.redeemScriptType = .none
    }
    
    init(input: Transaction.Input) throws {
      let scriptSigChunks = try Script.decompile(data: input.script)
      let sigType = ScriptType(input: scriptSigChunks)
      let chunks: [Data]
      let script: Data?
      if sigType == .p2sh {
        redeemScript = scriptSigChunks[scriptSigChunks.endIndex - 1]
        redeemScriptType = ScriptType(output: [redeemScript!])
        prevOutScript = try TemplateType.scriptHash.output.encode(data: redeemScript!.hash160)
        prevOutType = .p2sh
        signScript = redeemScript!
        signType = ScriptType.p2sh
        witness = false
        script = redeemScript
        chunks = scriptSigChunks
      } else {
        prevOutType = try ScriptType(input: input.script)
        signType = prevOutType
        witness = false
        prevOutScript = nil
        redeemScript = nil
        redeemScriptType = .none
        chunks = scriptSigChunks
        script = nil
        signScript = nil
      }
      
      let extracted = Transaction.Input.Expanded.extract(chunks: chunks,
                                                        type: signType,
                                                        script: script)
      
      publicKeys = extracted.pubKeys
      signatures = extracted.signatures
    }
    
    fileprivate static func extract(chunks: [Data], type: ScriptType, script: Data? = nil) -> (pubKeys: [Data], signatures: [Data]) {
      let pubKeys: [Data]
      let signatures: [Data]
      
      switch type {
      case .p2pkh:
        pubKeys = [Data](chunks[chunks.startIndex + 1 ..< chunks.endIndex])
        signatures = [chunks[0]]
      case .p2pk:
        if let script = script {
          if let first = try? Script.decompile(data: script)[0] {
            pubKeys = [first]
          } else {
            pubKeys = []
          }
        } else {
          pubKeys = []
        }
        signatures = [chunks[0]]
      default:
        pubKeys = []
        signatures = []
      }
      
      return (pubKeys: pubKeys, signatures: signatures)
    }
  }
}
