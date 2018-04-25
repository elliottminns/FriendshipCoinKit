//
//  SmsgPingHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct SmsgPingHandler: MessageHandler {
  func handle(message: Message, from peer: Peer) {
    
  }
  
  func handles(message: Message) -> Bool {
    return message.type == "smsgPing"
  }
}
