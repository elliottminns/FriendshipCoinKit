//


//  TransactionBuilder.swift
//  CoinKit
//
//  Created by Elliott Minns on 02/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public class TransactionBuilder<T: Transaction> {
  
  public fileprivate(set) var inputs: [T.Input] = []
  
  public fileprivate(set) var outputs: [TransactionOutput] = []
  
  let network: Network
  
  var version: UInt32?
  
  var locktime: UInt32?
  
  var values: [Int: UInt64] = [:]
  
  var timestamp: UInt32 = UInt32(Date().timeIntervalSince1970)
  
  fileprivate var signatures: [Int: Data] = [:]
  
  fileprivate var inputDetails: [Int: InputDetails] = [:]
  
  public init(network: Network) {
    self.network = network
  }
  
  public init(transaction: T, network: Network) {
    self.version = transaction.version
    self.locktime = transaction.locktime
    self.network = network
    self.timestamp = transaction.timestamp
    
    transaction.outputs.forEach { output in
      self.add(output: output.script, amount: output.amount)
    }
    
    transaction.inputs.forEach { input in
      try? self.add(input: input)
    }
  }
  
  func add(output script: Data, amount: UInt64) {
    let output = TransactionOutput(amount: amount, script: script)
    self.add(output: output)
  }
  
  public func add(output address: String, amount: UInt64) throws {
    let script = try Address(address: address, network: network).toOutputScript()
    self.add(output: script, amount: amount)
  }
  
  public func add(input transaction: T, outputIndex: Int) throws {
    let previous = transaction.outputs[outputIndex]
    let index = inputs.count
    let input = T.Input(hash: transaction.hash, index: UInt32(outputIndex), script: previous.script, sequence: 4294967295)
    try add(input: input)
    values[index] = previous.amount
  }
  
  func add(output: TransactionOutput) {
    self.outputs.append(output)
  }
  
  func add(input: T.Input) throws {
    let index = self.inputs.count
    self.inputs.append(input)
    
    let details = try InputDetails(input: input)
    self.inputDetails[index] = details
  }
  
  public func build() throws -> T {
    guard self.inputs.count > 0 && outputs.count > 0 else {
      throw Error.incompleteTransaction
    }
    
    let inputs = try self.inputs.enumerated().map { obj -> T.Input in
      let built = try build(input: obj.offset)
      let input = obj.element
      let script = built.script
      return T.Input(hash: input.hash, index: input.index, script: script, sequence: input.sequence)
    }
    return T(version: self.version ?? 1, timestamp: timestamp, locktime: locktime ?? 0, inputs: inputs, outputs: outputs)
  }
  
  public func sign(transaction: T, vin: Int, keyPair: ECPair) throws {
    try self.sign(transaction: transaction, vin: vin, signable: keyPair)
  }
  
  func sign(transaction: T, vin: Int, signable: Signable) throws {
    guard network.isEqual(signable.network) else { return }
    guard vin < inputs.count else { throw Error.invalidIndex }
    guard let inputDetail = inputDetails[vin] else { throw Error.invalidIndex }
    
    var input = inputDetail
    
    let publicKey = signable.publicKey
    let hashType = TransactionConstant.sighashAll
    
    
    if (!inputDetail.canSign) {
      input = try prepare(key: signable)
      inputDetails[vin] = input
    }
 
    let signatureHash = try transaction.hashForSignature(index: vin,
                                                         prevOutScript: input.signScript ?? Data(),
                                                         hashType: hashType)

    input.signatures = []
    let signed = try input.publicKeys.enumerated().map { item -> Bool in
      let pubKey = item.element
      guard publicKey == pubKey else { return false }

      if publicKey.count != 33 && (
        input.signType == .p2wpkh ||
          input.redeemScriptType == ScriptType.p2wsh ||
          input.prevOutType == ScriptType.p2wsh
        ) {
        return false
      }
      
      let signature = try signable.sign(signatureHash)
      let data = try signature.toScriptSignature(hashType: hashType)
      inputDetails[vin]?.signatures.append(data)
      return true
    }
    
    let success = signed.reduce(false) {
      return $0 || $1
    }
    
    if !success { throw Error.couldNotSign }
  }
  
  func details(for index: Int) throws -> InputDetails {
    if let details = self.inputDetails[index] { return details }
    return try InputDetails(input: inputs[index])
  }
  
  func prepare(key: Signable) throws -> InputDetails {
    let publicKey = key.publicKey
    let prevOutScript = try TemplateType.pubKeyHash.output.encode(data: publicKey.hash160)
    let expanded = try expand(output: prevOutScript, scriptType: .p2pkh, publicKey: publicKey)
    let prevOutType = ScriptType.p2pkh
    let witness = false
    let signType = prevOutType
    let signScript = prevOutScript
    
    return InputDetails(publicKeys: expanded.publicKeys, signatures: [],
                        signScript: signScript, signType: signType,
                        prevOutType: prevOutType,
                        prevOutScript: prevOutScript, witness: witness)
  }
  
  fileprivate func canSign(input: TransactionInput) -> Bool {
    return false
  }
    
  func expand(output script: Data, scriptType: ScriptType?, publicKey: Data) throws -> (publicKeys: [Data], scriptType: ScriptType) {
    let chunks = try Script.decompile(data: script)
    let type = scriptType ?? ScriptType(input: chunks)
    
    let publicKeys: [Data]
    
    switch type {
    case .p2pkh:
      let pkh1 = chunks[2]
      let pkh2 = publicKey.hash160
      if (pkh1 == pkh2) { publicKeys = [publicKey] } else { publicKeys = [] }
    default:
      publicKeys = []
    }
    
    return (publicKeys: publicKeys, scriptType: type)
  }
  
  fileprivate func build(input index: Int)  throws -> (type: ScriptType, script: Data) {
    guard let inputDetail = self.inputDetails[index] else { throw Error.invalidIndex }

    let scriptType = inputDetail.prevOutType
    let sig: [Data]
    
    if scriptType == .p2sh {
      if inputDetail.redeemScriptType.signable {
        sig = buildStack(type: inputDetail.redeemScriptType,
                         signatures: inputDetail.signatures,
                         pubKeys: inputDetail.publicKeys)
      } else {
        sig = []
      }
    } else if scriptType.signable {
      sig = buildStack(type: scriptType, signatures: inputDetail.signatures, pubKeys: inputDetail.publicKeys)
    } else {
      sig = []
    }
    
    let script = Script.compile(chunks: sig)
    return (type: scriptType, script: script)
  }
  
  fileprivate func buildStack(type: ScriptType, signatures: [Data], pubKeys: [Data]) -> [Data] {
    if type == .p2pkh {
      if let sig = signatures.first, let pubKey = pubKeys.first {
        return TemplateType.pubKeyHash.input.encodeStack(signature: sig, pubKey: pubKey)
      }
    } else if type == .p2pk {
      if let sign = signatures.first {
        return [sign]
      }
    }
    
    return []
  }
    
}

extension TransactionBuilder {
  struct InputDetails {
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
    
    init(input: TransactionInput) throws {
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
      
      let extracted = InputDetails.extract(chunks: chunks,
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

extension TransactionBuilder {
  enum Error: Swift.Error {
    case invalidIndex
    case invalidHash
    case duplicateHash
    case incompleteTransaction
    case inconsistentNetwork
    case couldNotSign
  }
}
