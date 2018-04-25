//
//  PeerHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol PeerHandlerDelegate: class {
  func peerHandlerDidTimeout(handler: PeerHandler)
}

struct PeerHandler: Hashable, MessageHandler {
  
  enum Error: Swift.Error {
    case timeout
  }
  
  let id: UUID
  
  let handler: MessageHandler
  
  let callback: (Result<Message>, Peer) -> Void
  
  unowned let delegate: PeerHandlerDelegate
  
  var hashValue: Int { return id.hashValue }
  
  let timer: Timer
  
  unowned let peer: Peer
  
  init(messageHandler: MessageHandler,
       delegate: PeerHandlerDelegate,
       peer: Peer,
       callback: @escaping (Result<Message>, Peer) -> Void,
       timeout: TimeInterval) {
    self.id = UUID()
    self.delegate = delegate
    self.handler = messageHandler
    self.callback = callback
    self.peer = peer
    timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { _ in
      callback(.failure(Error.timeout), peer)
    })
  }

  static func ==(lhs: PeerHandler, rhs: PeerHandler) -> Bool {
    return lhs.id == rhs.id
  }
  
  func handles(message: Message) -> Bool {
    let handles = handler.handles(message: message)
    print("HANDLE : \(message.type) - \(handles)")
    if handles {
      timer.invalidate()
    }
    return handles
  }
  
  func handle(message: Message, from peer: Peer) {
    handler.handle(message: message, from: peer)
    callback(.success(message), peer)
  }
}
