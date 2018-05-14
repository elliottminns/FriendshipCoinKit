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
  func peerHandlerDidHandle(handler: PeerHandler)
}

extension Peer {
  enum Error: Swift.Error {
    case timeout
  }
}

class PeerHandler: Hashable, MessageHandler {
  
  let id: UUID
  
  let handler: MessageHandler
  
  let timeoutHandler: TimeoutHandler
  
  unowned let delegate: PeerHandlerDelegate
  
  var hashValue: Int { return id.hashValue }
  
  var timer: Timer?
  
  var timedOut: Bool = false
  
  unowned let peer: Peer
  
  init(messageHandler: MessageHandler,
       delegate: PeerHandlerDelegate,
       peer: Peer,
       timeout: TimeInterval,
       onTimeout timeoutHandler: @escaping TimeoutHandler) {
    self.id = UUID()
    self.delegate = delegate
    self.handler = messageHandler
    self.timeoutHandler = timeoutHandler
    self.peer = peer
    timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { _ in
      self.timedOut = true
      timeoutHandler(peer)
      delegate.peerHandlerDidTimeout(handler: self)
    })
  }

  static func ==(lhs: PeerHandler, rhs: PeerHandler) -> Bool {
    return lhs.id == rhs.id
  }
  
  func handles(message: Message) -> Bool {
    guard !timedOut else { return false }
    let handles = handler.handles(message: message)
    return handles
  }
  
  func handle(message: Message, from peer: Peer) {
    guard !timedOut else { return }
    handler.handle(message: message, from: peer)
    if handler.isFinished || timer?.isValid == false {
      timer?.invalidate()
      delegate.peerHandlerDidHandle(handler: self)
    }
  }
}
