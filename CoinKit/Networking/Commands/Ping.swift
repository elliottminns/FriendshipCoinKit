//
//  Ping.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct Ping: Command, MessageHandler {
    let name: String = "ping"

    let nonce: UInt64
    
    init() {
      self.nonce = UInt64.pseudoRandom
    }
    
    func encode() -> Data {
      return Data(bytes: self.nonce.bytes.reversed())
    }
    
    func handles(message: Message) -> Bool {
      return message.type == "pong" && message.value.bytes.reversed() == self.nonce.bytes
    }
    
    func handle(message: Message, from peer: Peer) {
      peer.successfulPing(nonce: self.nonce)
    }
  }
}
