//
//  InventoryHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 29/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class InventoryHandler: MessageHandler {
  
  let callback: (Result<[Data]>, Peer) -> Void
  
  init(callback: @escaping (Result<[Data]>, Peer) -> Void) {
    self.callback = callback
  }
  
  func handle(message: Message, from peer: Peer) {
    let reader = DataReader(data: message.value)
    
    // Count
    let count = reader.readVariableInt()
    
    var hashes: [Data] = []
    
    while !reader.isEnded {
      // Inventory type
      let _: UInt32 = (try? reader.read(endian: .little)) ?? 0
      guard let bytes = try? reader.read(bytes: 32) else { continue }
      hashes.append(bytes)
    }
    callback(.success(hashes), peer)
  }
  
  func handles(message: Message) -> Bool {
    return message.type == "inv"
  }
}
