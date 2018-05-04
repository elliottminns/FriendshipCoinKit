//
//  Template.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

enum TemplateType {
  case version
  case script
  case pubKeyHash
  case scriptHash
  case publicKey
}

extension TemplateType: Template {
  var input: TemplateInput {
    switch self {
    case .version, .pubKeyHash: return VersionTemplate.Input()
    case .script, .scriptHash: return ScriptTemplate.Input()
    case .publicKey: return PublicKeyTemplate.Input()
    }
  }
  
  var output: TemplateOutput {
    switch self {
    case .version, .pubKeyHash: return VersionTemplate.Output()
    case .script, .scriptHash: return ScriptTemplate.Output()
    case .publicKey: return PublicKeyTemplate.Output()
    }
  }
}

protocol Template {
  var input: TemplateInput { get }
  var output: TemplateOutput { get }
}

protocol TemplateInput {
  func check(data: [Data]) -> Bool
  func encodeStack(signature: Data, pubKey: Data) -> [Data]
}

extension TemplateInput {
  func check(data: Data) throws -> Bool {
    let chunks = try Script.decompile(data: data)
    return self.check(data: chunks)
  }
}

protocol TemplateOutput {
  func encode(data: Data) throws -> Data
  func check(data: [Data]) -> Bool
}

extension TemplateOutput {
  func check(data: Data) -> Bool {
    do {
      let d = try Script.decompile(data: data)
      return check(data: d)
    } catch _ {
      return false
    }
  }
}
