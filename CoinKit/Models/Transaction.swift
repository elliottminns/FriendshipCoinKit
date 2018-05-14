//
//  Transaction.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol Transaction {
  
  associatedtype Input: TransactionInput
  
  var id: String { get }

  var hash: Data { get }
  
  var version: UInt32 { get }
  
  var inputs: [Input] { get }
  
  var timestamp: UInt32 { get }
  
  var outputs: [TransactionOutput] { get }
  
  var locktime: UInt32 { get }
  
  init(version: UInt32, timestamp: UInt32, locktime: UInt32, inputs: [Input], outputs: [TransactionOutput])
  
  func hashForSignature(index: Int, prevOutScript: Data, hashType: UInt8) throws -> Data
  
  func toData() -> Data
  
  init(data: Data) throws
}

public extension Transaction {
  
  public func toData() -> Data {
    var data = Data()
    data.append(bytesFrom: version, endian: .little)
    data.append(bytesFrom: timestamp, endian: .little)
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
    
    data.append(bytesFrom: locktime, endian: .little)
    
    return data
  }
  
  public func hashForSignature(index: Int, prevOutScript: Data, hashType: UInt8) throws -> Data {
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
        return Self.Input(hash: ipt.hash, index: ipt.index, script: ipt.script,
                          sequence: 0)
      }
    }
    
    var outs: [TransactionOutput] = self.outputs
    var ins: [Input] = self.inputs
    
    if (hashType & 0x1f) == TransactionConstant.sighashNone {
      outs = []
      ins = inputSequenceModifier(ins)
    } else if (hashType & 0x1f) == TransactionConstant.sighashSingle {
      guard index < outputs.count else { return one }
      outs = (0 ..< index).map { _ in return TransactionOutput.blank }
      ins = inputSequenceModifier(ins)
    }
    
    if hashType & TransactionConstant.sighashAnyoneCanPay != 0 {
      let input = ins[index]
      ins = [
        Input(hash: input.hash, index: input.index, script: ourScript,
              sequence: input.sequence)
      ]
    } else {
      ins = ins.enumerated().map { item -> Input in
        let script = item.offset == index ? ourScript : Data()
        let i = item.element
        return Input(hash: i.hash, index: i.index, script: script, sequence: i.sequence)
      }
    }
    
    let tx = Self(version: self.version, timestamp: self.timestamp, locktime: self.locktime, inputs: ins, outputs: outs)
    var buffer = Data()
    buffer.append(tx.toData())
    buffer.append(bytesFrom: UInt32(hashType), endian: .little)
    return Data(buffer.sha256.sha256)
  }
}

struct TransactionConstant {
  static let advancedTransactionMarker: UInt8 = 0x00
  static let advancedTransactionFlag: UInt8 = 0x01
  static let sighashNone: UInt8 = 0x02
  static let sighashSingle: UInt8 = 0x03
  static let sighashAnyoneCanPay: UInt8 = 0x80
  static let sighashAll: UInt8 = 0x01
}

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
