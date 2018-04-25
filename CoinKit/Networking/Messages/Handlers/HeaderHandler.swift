//
//  HeaderHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct HeaderHandler: MessageHandler {
  
  func handle(message: Message, from peer: Peer) {
    
    let reader = DataReader(data: message.value)
    
    repeat {
      let version: Int32 = reader.read(endian: .little)
      let previousHash: Data = reader.read(bytes: 32)
      let merkleRoot: Data = reader.read(bytes: 32)
      let timestamp: UInt32 = reader.read(endian: .little)
      let bits: UInt32 = reader.read(endian: .little)
      let nonce: UInt32 = reader.read(endian: .little)
      let transactionsCount: UInt = reader.readVariableInt()
   
      let header = BlockHeader(hash: Data(), version: version,
                               prevHash: previousHash, merkleRoot: merkleRoot,
                               bits: bits, nonce: nonce, timestamp: timestamp)
    } while !reader.isEnded
  }
  
  func handles(message: Message) -> Bool {
    return message.type == "header"
  }
}
