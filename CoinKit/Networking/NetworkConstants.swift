//
//  NetworkConstants.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

struct NetworkConstants {
  enum Inventory: UInt8 {
    case error = 0
    case msg_tx = 1
    case msg_block = 2
    case msg_filtered_block = 3
  }
}
