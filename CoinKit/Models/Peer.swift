//
//  Peer.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import UIKit

public class Peer {
  let socket: Socket
  
  let params: Params
  
  let options: Options
  
  init(socket: Socket, params: Params, options: Options = Options()) {
    self.socket = socket
    self.params = params
    self.options = options
  }
}

public extension Peer {
  public struct Params {
  }
  
  public struct Options {
    public let relay: Bool
    
    public let requireBloom: Bool
    
    public let userAgent: String
    
    public let handshakeTimeout: Int
    
    public let pingInterval: Int
    
    public init(relay: Bool = true, requireBloom: Bool = true,
                handshakeTimeout: Int = 8000, pingInterval: Int = 15000) {
      self.relay = relay
      self.requireBloom = requireBloom
      self.userAgent = "/CoinKit:1.0/CoinKit:1.0"
      self.handshakeTimeout = handshakeTimeout
      self.pingInterval = pingInterval
    }
  }
}
