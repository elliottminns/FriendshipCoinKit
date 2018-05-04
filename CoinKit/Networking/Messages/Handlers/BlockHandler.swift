//
//  BlockHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class BlockHandler<T: Block>: MessageHandler {
  
  let callback: ((Result<[T]>, Peer) -> Void)
  
  let hashingAlgorithm: HashingAlgorithm
  
  var blocks: [T] = []
  
  let hashes: Set<Data>?

  var isFinished: Bool = false
  
  init(hashes: [Data]? = nil, hashingAlgorithm: HashingAlgorithm, callback: @escaping (Result<[T]>, Peer) -> Void) {
    self.callback = callback
    self.hashingAlgorithm = hashingAlgorithm
    
    if let hashes = hashes {
      self.hashes = Set<Data>(hashes)
    } else {
      self.hashes = nil
    }
  }

  func handle(message: Message, from peer: Peer) {
    do {
      let block = try T.init(data: message.value)
      blocks.append(block)
      if let hashes = hashes {
        if hashes.count == blocks.count {
          isFinished = true
          callback(.success(blocks), peer)
        }
      } else {
        isFinished = true
        callback(.success(blocks), peer)
      }
    } catch let error  {
      callback(.failure(error), peer)
    }
  }
  
  func handles(message: Message) -> Bool {
    guard message.type == "block" else { return false }
    guard let hashes = self.hashes else { return true }
    return hashes.contains(hashingAlgorithm.hash(data: message.value))
  }
}
