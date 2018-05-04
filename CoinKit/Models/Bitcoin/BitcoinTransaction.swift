//
//  Transaction.swift
//  CoinKit
//
//  Created by Elliott Minns on 02/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

fileprivate extension Int {
  var encodingLength: UInt {
    
    return (
      self < 0xfd ? 1
        : self <= 0xffff ? 3
        : self <= 0xffffffff ? 5
        : 9
    )
  }
}

fileprivate extension Data {
  var encodingLength: UInt {
    return count.encodingLength + UInt(count)
  }
}

fileprivate extension Sequence where Element == Data {
  var encodingLength: UInt {
    return self.reduce(0) { $0 + $1.encodingLength }
  }
}

public struct BitcoinTransaction: Transaction {
  
  struct Constant {
    static let advancedTransactionMarker: UInt8 = 0x00
    static let advancedTransactionFlag: UInt8 = 0x01
    static let sighashNone: UInt8 = 0x02
    static let sighashSingle: UInt8 = 0x03
    static let sighashAnyoneCanPay: UInt8 = 0x80
    static let sighashAll: UInt8 = 0x01
  }
  
  enum Error: Swift.Error {
    case invalidHex
  }
  
  var id: String {
    return Data(toData(allowWitness: false).sha256.sha256.reversed()).hexEncodedString()
  }

  let version: UInt32
  
  let inputs: [Input]
  
  let outputs: [Output]
  
  let locktime: UInt32
  
  var weight: UInt {
    let base = byteLength(allowWitness: false)
    let total = byteLength(allowWitness: true)
    return base * 3 + total
  }
  
  var virtualSize: UInt {
    return weight / 4
  }
  
  var hasWitnesses: Bool {
    return inputs.filter { $0.witness.count > 0 }.count > 0
  }
  
  public init(version: UInt32, locktime: UInt32, inputs: [Input], outputs: [Output]) {
    self.version = version
    self.locktime = locktime
    self.inputs = inputs
    self.outputs = outputs
  }
  
  public init(hex: String) throws {
    guard let data = hex.hexadecimal() else {
      throw Error.invalidHex
    }
    
    self.init(data: data)
  }
  
  public init(data: Data) {
    let reader = DataReader(data: data)
    self.init(reader: reader)
  }
  
  public init(reader: DataReader) {
    version = reader.read(endian: .little)
    
    let marker = reader.next()
    let flag = reader.next()
    
    let hasWitness: Bool
    if marker == Constant.advancedTransactionMarker &&
      flag == Constant.advancedTransactionFlag {
      hasWitness = true
    } else {
      hasWitness = false
      reader.move(positionBy: -2)
    }
    
    let vinLength = reader.readVariableInt()
    let range = (0 ..< vinLength)
    
    let inputs = range.map { (index: UInt) -> Input in
      let hash = reader.read(bytes: 32)
      let idx: UInt32 = reader.read(endian: .little)
      let script = reader.readVariableBytes()
      let sequence: UInt32 = reader.read(endian: .little)
      return Input(hash: hash, index: idx, script: script, sequence: sequence)
    }

    let vout = reader.readVariableInt()
    
    let voutRange = (0 ..< vout)
    let outputs = voutRange.map { (index: UInt) -> Output in
      let value: UInt64 = reader.read(endian: .little)
      let script = reader.readVariableBytes()
      return Output(amount: value, script: script)
    }
    
    if hasWitness {
      self.inputs = inputs.map { $0.add(witness: reader.readVector()) }
    } else {
      self.inputs = inputs
    }
    
    self.outputs = outputs
    self.locktime = reader.read(endian: .little)
  }
  
  func byteLength(allowWitness: Bool) -> UInt {
    let hasWitnesses = allowWitness && self.hasWitnesses
    return (
      (hasWitnesses ? 10 : 8) +
      inputs.count.encodingLength +
      outputs.count.encodingLength +
      inputs.reduce(0) { return $0 + 40 + $1.script.encodingLength } +
      outputs.reduce(0) { return $0 + 8 + $1.script.encodingLength } +
        (hasWitnesses ? inputs.reduce(0) { $0 + $1.witness.encodingLength } : 0)
    )
  }
  
  func toData(allowWitness: Bool) -> Data {
    var data = Data()
    data.append(bytesFrom: version, endian: .little)

    let hasWitnesses = self.hasWitnesses && allowWitness
    if hasWitnesses {
      data.append(bytesFrom: Constant.advancedTransactionMarker, endian: .little)
      data.append(bytesFrom: Constant.advancedTransactionFlag, endian: .little)
    }
    
    data.append(variable: inputs.count, endian: .little)
    
    inputs.forEach { input in
      data.append(input.hash)
      data.append(bytesFrom: input.index, endian: .little)
      data.append(variable: input.script, endian: .little)
      data.append(bytesFrom: input.sequence, endian: .little)
    }
    
    data.append(variable: outputs.count, endian: .little)
    
    outputs.forEach { output in
      data.append(bytesFrom: output.amount, endian: .little)
      data.append(variable: output.script, endian: .little)
    }
    
    if hasWitnesses {
      inputs.forEach { input in
        data.append(variable: input.witness.count, endian: .little)
        input.witness.forEach { data.append($0) }
      }
    }
    
    data.append(bytesFrom: locktime, endian: .little)
    
    return data
  }
  
  func hashForSignature(index: UInt32, prevOutScript: Data, hashType: UInt8) throws -> Data {
    return try self.hashForSignature(index: Int(index), prevOutScript: prevOutScript, hashType: hashType)
  }
  
  func hashForSignature(index: Int, prevOutScript: Data, hashType: UInt8) throws -> Data {
    let one = "0000000000000000000000000000000000000000000000000000000000000001".hexadecimal()!
    
    guard index < inputs.count else { return one }
    
    let decompiled = try Script.decompile(data: prevOutScript).filter {
      $0.bytes != [OPCodes.OP_CODESEPARATOR.value]
    }
    let ourScript = Script.compile(chunks: decompiled)

    let inputSequenceModifier = { (ins: [Input]) -> [Input] in
      return ins.enumerated().map { item -> Input in
        guard item.offset != index else { return item.element }
        let ipt = item.element
        return Input(hash: ipt.hash, index: ipt.index, script: ipt.script,
                     sequence: ipt.sequence, witness: ipt.witness)
      }
    }
    
    var outs: [Output] = self.outputs
    var ins: [Input] = self.inputs
    
    if (hashType & 0x1f) == Constant.sighashNone {
      outs = []
      ins = inputSequenceModifier(ins)
    } else if (hashType & 0x1f) == Constant.sighashSingle {
      guard index < outputs.count else { return one }
      outs = (0 ..< index).map { _ in return Output.blank }
      ins = inputSequenceModifier(ins)
    }
    
    if hashType & Constant.sighashAnyoneCanPay != 0 {
      let input = ins[index]
      ins = [
        Input(hash: input.hash, index: input.index, script: ourScript,
              sequence: input.sequence, witness: input.witness)
      ]
    } else {
      ins = ins.enumerated().map { item -> Input in
        let script = item.offset == index ? ourScript : Data()
        let i = item.element
        return Input(hash: i.hash, index: i.index, script: script, sequence: i.sequence, witness: i.witness)
      }
    }
    
    let tx = BitcoinTransaction(version: self.version, locktime: self.locktime, inputs: ins, outputs: outs)
    var buffer = Data()
    buffer.append(tx.toData(allowWitness: false))
    buffer.append(bytesFrom: UInt32(hashType), endian: .little)
    return buffer.sha256.sha256
  }
}
