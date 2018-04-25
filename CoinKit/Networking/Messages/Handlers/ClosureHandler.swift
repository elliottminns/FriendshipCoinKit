//
//  ClosureHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct ClosureHandler: MessageHandler {
  
  let callback: (Data, Peer) -> Void
  
  let handleType: String
  
  init(handleType: String, callback: @escaping (Data, Peer) -> Void) {
    self.callback = callback
    self.handleType = handleType
  }
  
  func handle(message: Message, from peer: Peer) {
    callback(message.value, peer)
  }
  
  func handles(message: Message) -> Bool {
    return message.type == self.handleType
  }
  
}
