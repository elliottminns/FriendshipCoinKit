//
//  PingHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class PingHandler: MessageHandler {
  func handles(message: Message) -> Bool {
    return message.type == "ping"
  }
  
  func handle(message: Message, from peer: Peer) {
    
    let command = CommandType.Pong(nonce: message.value)
    peer.send(command: command)
  }
}
