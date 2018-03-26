//
//  Network.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public enum Network {
  case bitcoin
  case testnet
  case litecoin
  case friendshipcoin
  case other(version: UInt8)
}

extension Network {
  var version: UInt8 {
    switch self {
    case .bitcoin: return 0x00
    case .litecoin: return 0x30
    case .testnet: return 0x02
    case .friendshipcoin: return 95
    case .other(let version): return version
    }
  }
}
