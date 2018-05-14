//
//  TransactionHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 14/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class TransactionHandler<T: Transaction>: MessageHandler {
  
  let callback: ((Result<[T]>, Peer) -> Void)
  
  var transactions: [T] = []
  
  let hashes: Set<Data>?
  
  var isFinished: Bool = false
  
  init(hashes: [Data]? = nil, callback: @escaping (Result<[T]>, Peer) -> Void) {
    self.callback = callback

    if let hashes = hashes {
      self.hashes = Set<Data>(hashes)
    } else {
      self.hashes = nil
    }
  }
  
  func handle(message: Message, from peer: Peer) {
    do {
      let block = try T.init(data: message.value)
      transactions.append(block)
      if let hashes = hashes {
        if hashes.count == transactions.count {
          isFinished = true
          callback(.success(transactions), peer)
        }
      } else {
        isFinished = true
        callback(.success(transactions), peer)
      }
    } catch let error  {
      callback(.failure(error), peer)
    }
  }
  
  func handles(message: Message) -> Bool {
    guard message.type == "tx" else { return false }
    guard let hashes = self.hashes else { return true }
    
    return hashes.contains(message.value.sha256.sha256)
  }
}

