//
//  TransactionBuilder.swift
//  CoinKit
//
//  Created by Elliott Minns on 02/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension BitcoinTransaction {
  
  public class Builder {
    
    enum Error: Swift.Error {
      case invalidIndex
      case invalidHash
      case duplicateHash
      case incompleteTransaction
      case inconsistentNetwork
      case couldNotSign
    }
    
    var inputs: [BitcoinTransaction.Input] = []
    
    var outputs: [BitcoinTransaction.Output] = []
    
    var ins: [BitcoinTransaction.Input.Expanded] = []
    
    var version: UInt32?

    var locktime: UInt32?
    
    fileprivate var inputHashes: Set<Data> = []
    
    let network: Network
    
    var signatures: [UInt32: [UInt32: Data]] = [:]
    
    init(network: Network) {
      self.network = network
    }
    
    init(transaction: BitcoinTransaction, network: Network) {
      self.version = transaction.version
      self.locktime = transaction.locktime
      self.network = network
      
      transaction.outputs.forEach { output in
        self.add(output: output.script, amount: output.amount)
      }
      
      transaction.inputs.forEach { input in
        _ = try? self.add(input: input)
      }
    }
    
    func add(transaction: BitcoinTransaction) throws -> UInt {
      return try self.add(transaction: transaction.id)
    }
    
    func add(transaction: String) throws -> UInt {
      let index = inputs.count + 1
      let data = transaction.hexadecimal()!
      let input = BitcoinTransaction.Input(hash: data, index: UInt32(index))
      return try self.add(input: input)
    }
    
    func add(input: String, vout: UInt32) throws {
      guard let hex = input.hexadecimal() else { throw Error.invalidHash }
      let hash = Data(hex.reversed())
      let input = Input(hash: hash, index: vout)
      try add(input: input)
    }
    
    @discardableResult func add(input: BitcoinTransaction.Input) throws -> UInt {
      guard !inputHashes.contains(input.hash) else {
        throw Error.duplicateHash
      }
      inputs.append(input)
      let inputEx = try Input.Expanded(input: input)
      ins.append(inputEx)
      return UInt(input.index)
    }
    
    func add(output address: String, amount: UInt64) throws {
      let script = try Address(address: address, network: network).toOutputScript()
      self.add(output: script, amount: amount)
    }
    
    func add(output script: Data, amount: UInt64) {
      let output = BitcoinTransaction.Output(amount: amount, script: script)
      self.add(output: output)
    }
    
    func add(output: BitcoinTransaction.Output) {
      self.outputs.append(output)
    }
    
    func build() throws -> BitcoinTransaction {
      guard self.inputs.count > 0 && outputs.count > 0 else {
        throw Error.incompleteTransaction
      }
      
      let inputs = try self.inputs.enumerated().map { obj -> BitcoinTransaction.Input in
        let built = try build(input: obj.offset)
        let input = obj.element
        return BitcoinTransaction.Input(hash: input.hash, index: input.index, script: built.script, sequence: input.sequence, witness: input.witness)
      }
      return BitcoinTransaction(version: self.version ?? 1, locktime: locktime ?? 0, inputs: inputs, outputs: outputs)
    }
    
    func sign(vin: Int, keyPair: ECPair) throws {
      try self.sign(vin: vin, signable: keyPair)
    }
    
    func sign(vin: Int, signable: Signable) throws {
      guard network.isEqual(signable.network) else { return }
      guard vin < ins.count else { throw Error.invalidIndex }

      var input = ins[vin]
      let publicKey = signable.publicKey
      let hashType = BitcoinTransaction.Constant.sighashAll
      
      if !input.canSign {
        input = try prepare(input: input, key: signable)
        ins[vin] = input
      }
      
      let transaction = BitcoinTransaction(version: version ?? 1, locktime: locktime ?? 0, inputs: inputs, outputs: outputs)
      
      let signatureHash = try transaction.hashForSignature(index: vin,
                                                           prevOutScript: input.signScript ?? Data(),
                                                           hashType: hashType)
      
      input.signatures = []
      let signed = try input.publicKeys.enumerated().map { item -> Bool in
        let pubKey = item.element
        guard publicKey == pubKey else { return false }
        //guard input.signatures.count < item.offset else { return false }
        
        if publicKey.count != 33 && (
          input.signType == .p2wpkh ||
          input.redeemScriptType == ScriptType.p2wsh ||
          input.prevOutType == ScriptType.p2wsh
          ) {
          return false
        }
        
        let signature = try signable.sign(signatureHash)
        let data = try signature.toScriptSignature(hashType: hashType)
        ins[vin].signatures.append(data)
        return true
      }
      
      let success = signed.reduce(false) {
        return $0 || $1
      }
      
      if !success { throw Error.couldNotSign }
    }
    
    fileprivate func build(input index: Int)  throws -> (type: ScriptType, script: Data) {
      guard index < ins.count else { throw Error.invalidIndex }
      let exInput = ins[index]
      
      let scriptType = exInput.prevOutType
      let sig: [Data]
      
      if scriptType == .p2sh {
        if exInput.redeemScriptType.signable {
          sig = buildStack(type: exInput.redeemScriptType,
                               signatures: exInput.signatures,
                               pubKeys: exInput.publicKeys)
        } else {
          sig = []
        }
      } else if scriptType.signable {
        sig = buildStack(type: scriptType, signatures: exInput.signatures, pubKeys: exInput.publicKeys)
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

    func prepare(input: Input.Expanded, key: Signable) throws -> Input.Expanded {
      let publicKey = key.publicKey
      let prevOutScript = try TemplateType.pubKeyHash.output.encode(data: publicKey.hash160)
      let expanded = try expand(output: prevOutScript, scriptType: .p2pkh, publicKey: publicKey)
      let prevOutType = ScriptType.p2pkh
      let witness = false
      let signType = prevOutType
      let signScript = prevOutScript
      
      return Input.Expanded(publicKeys: expanded.publicKeys, signatures: [],
                            signScript: signScript, signType: signType,
                            prevOutType: prevOutType,
                            prevOutScript: prevOutScript, witness: witness)
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
  }
}
