//
//  SigType.swift
//  CoinKit
//
//  Created by Elliott Minns on 21/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

enum ScriptType {
  case p2pkh
  case p2sh
  case p2wpkh
  case p2wsh
  case p2pk
  case nonstandard
  case none
}

extension ScriptType {
  init(input: Data) throws {
    let chunks = try Script.decompile(data: input)
    self.init(input: chunks)
  }
  
  init(input: [Data]) {
    if TemplateType.pubKeyHash.input.check(data: input) { self = .p2pkh }
    else if TemplateType.scriptHash.input.check(data: input) { self = .p2sh }
    else { self = .nonstandard }
  }
  
  init(output: [Data]) {
    if TemplateType.pubKeyHash.output.check(data: output) { self = .p2pkh }
    else if TemplateType.scriptHash.output.check(data: output) { self = .p2sh }
    else { self = .nonstandard }
  }
  
  var signable: Bool {
    return self == .p2pkh || self == .p2pk
  }
}
