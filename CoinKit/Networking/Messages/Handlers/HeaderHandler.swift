//
//  HeaderHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct HeaderHandler: MessageHandler {
  
  let callback: (Result<[BlockHeader]>, Peer) -> Void
  
  let hashingAlgorithm: HashingAlgorithm
  
  let locators: [Data]
  
  init(hashingAlgorithm: HashingAlgorithm, locators: [Data], callback: @escaping (Result<[BlockHeader]>, Peer) -> Void) {
    self.callback = callback
    self.hashingAlgorithm = hashingAlgorithm
    self.locators = locators
  }
  
  func handle(message: Message, from peer: Peer) {
    
    let reader = DataReader(data: message.value)
    
    var headers: [BlockHeader] = []
    
    // Header count
    let count = reader.readVariableInt()

    guard count > 0 else { return callback(.success([]), peer) }
    
    do {
      repeat {
        let version: Int32 = try reader.read(endian: .little)
        let previousHash: Data = Data(try reader.read(bytes: 32))
        let merkleRoot: Data = Data(try reader.read(bytes: 32))
        let timestamp: UInt32 = try reader.read(endian: .little)
        let bits: UInt32 = try reader.read(endian: .little)
        let nonce: UInt32 = try reader.read(endian: .little)
        let transactionsCount: UInt16 = try reader.read(endian: .little)
        
        let header = BlockHeader(version: version, prevHash: previousHash,
                                 merkleRoot: merkleRoot, bits: bits, nonce: nonce,
                                 timestamp: timestamp, transactionCount: transactionsCount,
                                 hashingAlgorithm: hashingAlgorithm)
        headers.append(header)
      } while !reader.isEnded
    
      DispatchQueue.main.async {
        self.callback(.success(headers), peer)
      }
    } catch let error {
      DispatchQueue.main.async {
        return self.callback(.failure(error), peer)
      }
    }
  }
  
  func handles(message: Message) -> Bool {
    guard message.type == "headers" else { return false }
    
    do {
      
      let reader = DataReader(data: message.value)
      let num = reader.readVariableInt()
      
      if num == 0 { return true }
      
      let _: Int32 = try reader.read(endian: .little)
      let previousHash = try reader.read(bytes: 32)
      
      let count = locators.filter { $0 == previousHash }.count
      return count > 0
    } catch _ {
      return false
    }
  }
}
