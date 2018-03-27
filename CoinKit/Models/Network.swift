//
//  Network.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol Network {
  var version: UInt8 { get }
  var bip32: (private: UInt32, public: UInt32) { get }
}

public enum NetworkType: Network {
  case bitcoin
  case testnet
  case litecoin
  case friendshipcoin
  case other(version: UInt8)
}

extension NetworkType {
  public var version: UInt8 {
    switch self {
    case .bitcoin: return 0x00
    case .litecoin: return 0x30
    case .testnet: return 0x02
    case .friendshipcoin: return 95
    case .other(let version): return version
    }
  }
  
  public var bip32: (private: UInt32, public: UInt32) {
    switch self {
    case .bitcoin: return (private: 0x0488ade4, public: 0x0488b21e)
    case .litecoin: return (private: 0x019d9cfe, public: 0x019da462)
    case .testnet: return (private: 0x04358394, public: 0x043587cf)
    case .friendshipcoin: return (private: 0x0488ade4, public: 0x0488b21e)
    case .other(_): return (private: 0, public: 0)
    }
  }
}
