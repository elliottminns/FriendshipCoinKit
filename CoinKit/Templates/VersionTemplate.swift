//
//  VersionTemplate.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct VersionTemplate: Template {

  struct Output: TemplateOutput {
   
    enum Error: Swift.Error {
      case incorrectData
    }
    
    func encode(data: Data) throws -> Data {
      guard data.count == 20 else { throw Error.incorrectData }
      
      let encoded = [
        Data([OPCodes.OP_DUP.value]),
        Data([OPCodes.OP_HASH160.value]),
        data,
        Data([OPCodes.OP_EQUALVERIFY.value]),
        Data([OPCodes.OP_CHECKSIG.value])
      ]
      
      return Script.compile(chunks: encoded)
    }
    
    func check(data: [Data]) -> Bool {
      let buffer = Script.compile(chunks: data)
      return buffer.count == 25 &&
        buffer[indexed: 0] == OPCodes.OP_DUP.value &&
        buffer[indexed: 1] == OPCodes.OP_HASH160.value &&
        buffer[indexed: 2] == 0x14 &&
        buffer[indexed: 23] == OPCodes.OP_EQUAL.value &&
        buffer[indexed: 24] == OPCodes.OP_CHECKSIG.value
    }
  }
  
  struct Input: TemplateInput {
    func check(data: [Data]) -> Bool {
      return data.count == 2 && Script(data: data[0]).isCanonicalSignature &&
        Script(data: data[1]).isCanonicalPubKey
    }
    
    func encodeStack(signature: Data, pubKey: Data) -> [Data] {
      return [signature, pubKey]
    }
  }
  
  let input: TemplateInput = Input()
  
  let output: TemplateOutput = Output()
}
