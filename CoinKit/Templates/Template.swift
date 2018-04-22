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
}

extension TemplateType: Template {
  var input: TemplateInput {
    switch self {
    case .version, .pubKeyHash: return VersionTemplate().input
    case .script, .scriptHash: return ScriptTemplate().input
    }
  }
  
  var output: TemplateOutput {
    switch self {
    case .version, .pubKeyHash: return VersionTemplate().output
    case .script, .scriptHash: return ScriptTemplate().output
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
