//
//  ScriptTemplate.swift
//  CoinKit
//
//  Created by Elliott Minns on 20/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct ScriptTemplate: Template {
  
  struct Output: TemplateOutput {
    
    enum Error: Swift.Error {
      case incorrectData
    }
    
    func encode(data: Data) throws -> Data {
      guard data.count == 20 else { throw Error.incorrectData }
      
      return Script.compile(chunks: [
        Data([OPCodes.OP_HASH160.value]),
        data,
        Data([OPCodes.OP_EQUALVERIFY.value])
      ])
    }
    
    func check(data: [Data]) -> Bool {
      let buffer = Script.compile(chunks: data)
      return buffer.count == 23 &&
        buffer[indexed: 0] == OPCodes.OP_HASH160.value &&
        buffer[indexed: 1] == 0x14 &&
        buffer[indexed: 22] == OPCodes.OP_EQUAL.value
    }
  }
  
  struct Input: TemplateInput {
    func check(data: [Data]) -> Bool {
      guard data.count > 0, let last = data.last else { return false }
      
      let allButEnd = [Data](data[data.startIndex ..< data.endIndex - 1])
      let compiled = Script.compile(chunks: allButEnd)
      guard let scriptSigChunks = try? Script.decompile(data: compiled),
        let redeemScriptChunks = try? Script.decompile(data: last),
        redeemScriptChunks.count > 0,
        Script.isPushOnly(chunks: scriptSigChunks) else {
          return false
      }
      
      if data.count == 1 { return false }
      
      if TemplateType.pubKeyHash.input.check(data: scriptSigChunks) &&
        TemplateType.pubKeyHash.output.check(data: redeemScriptChunks) {
        return true
      }
      
      return false
    }
    
    func encodeStack(signature: Data, pubKey: Data) -> [Data] {
      let serializedPubKey = Script.compile(chunks: [pubKey])
      return [signature, pubKey]
    }
    
  }
  
  let input: TemplateInput = Input()
  
  let output: TemplateOutput = Output()
}
