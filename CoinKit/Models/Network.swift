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
  var name: String { get }
  var script: UInt8 { get }
}

extension Network {
  func isEqual(_ other: Network) -> Bool {
    return version == other.version && bip32.private == other.bip32.private &&
      bip32.public == other.bip32.public && name == other.name && script == other.script
  }
}

public enum NetworkType: Network {
  case bitcoin
  case testnet
  case litecoin
  case friendshipcoin
}

extension NetworkType {
  
  public var version: UInt8 {
    switch self {
    case .bitcoin: return 0x00
    case .litecoin: return 0x30
    case .testnet: return 0x02
    case .friendshipcoin: return 0x5f
    }
  }
  
  public var bip32: (private: UInt32, public: UInt32) {
    switch self {
    case .bitcoin: return (private: 0x0488ade4, public: 0x0488b21e)
    case .litecoin: return (private: 0x019d9cfe, public: 0x019da462)
    case .testnet: return (private: 0x04358394, public: 0x043587cf)
    case .friendshipcoin: return (private: 0x0488ade4, public: 0x0488b21e)
    }
  }
  
  public var name: String {
    switch self {
    case .bitcoin: return "bitcoin"
    case .litecoin: return "litecoin"
    case .testnet: return "testnet"
    case .friendshipcoin: return "friendshipcoin"
    }
  }
  
  public var script: UInt8 {
    switch self {
    case .bitcoin: return 0x05
    case .testnet: return 0xc4
    case .litecoin: return 0x32
    case .friendshipcoin: return 0x23
    }
  }
}
