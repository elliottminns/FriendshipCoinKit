//
//  AddrHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 04/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol AddrHandlerDelegate: class {
  func handler(_ handler: AddrHandler, didReceiveAddrs addrs: [Addr])
}

class AddrHandler: MessageHandler {
  
  unowned let delegate: AddrHandlerDelegate
  
  init(delegate: AddrHandlerDelegate) {
    self.delegate = delegate
  }
  
  func handles(message: Message) -> Bool {
    return message.type == "addr"
  }
  
  func handle(message: Message, from peer: Peer) {
    do {
      let reader = DataReader(data: message.value)
      let count = reader.readVariableInt()
      
      var addrs: [Addr?] = []
      while !reader.isEnded {
        addrs.append(try Addr(reader: reader))
      }
      
      self.delegate.handler(self, didReceiveAddrs: addrs.compactMap { $0 })
      
    } catch _ {
      
    }
  }
  
}
