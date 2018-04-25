//
//  Pong.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct Pong: Command {
    let name: String = "pong"
    
    let nonce: Data

    init(nonce: UInt64) {
      self.nonce = Data(nonce.bytes.reversed())
    }
    
    init(nonce: Data) {
      self.nonce = nonce
    }
    
    func encode() -> Data {
      return nonce
    }
  }
}
