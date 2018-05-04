//
//  PublicKeyTemplate.swift
//  CoinKit
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct PublicKeyTemplate: Template {
  
  struct Input: TemplateInput {
    func check(data: [Data]) -> Bool {
//      return data.count == 1 &&
//        Script.isCanonicalSignature(chunks[0])
      return false
    }
    
    func encodeStack(signature: Data, pubKey: Data) -> [Data] {
      return [signature]
    }
  }
  
  struct Output: TemplateOutput {
    func check(data: [Data]) -> Bool {
      return false
    }
    
    func encode(data: Data) throws -> Data {
      return Data()
    }
  }
  
  var input: TemplateInput
  
  var output: TemplateOutput
  
  init() {
    self.input = Input()
    self.output = Output()
  }
  
}
