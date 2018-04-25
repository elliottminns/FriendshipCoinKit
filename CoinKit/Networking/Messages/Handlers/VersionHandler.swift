//
//  VersionHandler.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class VersionHandler: MessageHandler {
  func handles(message: Message) -> Bool {
    return message.type == "version"
  }
  
  func handle(message: Message, from peer: Peer) {
    let command = CommandType.Verack()
    peer.send(command: command)
  }
}
