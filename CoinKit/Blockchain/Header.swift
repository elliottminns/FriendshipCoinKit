//
//  Header.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct BlockHeader {
  
  public let version: Int32
  
  public let prevHash: Data
  
  public let merkleRoot: Data
  
  public let bits: UInt32
  
  public let nonce: UInt32
  
  public let timestamp: UInt32
  
  public init(version: Int32, prevHash: Data, merkleRoot: Data, bits: UInt32, nonce: UInt32, timestamp: UInt32) {
    self.version = version
    self.prevHash = prevHash
    self.merkleRoot = merkleRoot
    self.bits = bits
    self.nonce = nonce
    self.timestamp = timestamp
  }
}

extension BlockHeader: Equatable {
  public static func ==(lhs: BlockHeader, rhs: BlockHeader) -> Bool {
    let neoscrypt = NeoScrypt()
    return neoscrypt.hash(blockHeader: lhs) == neoscrypt.hash(blockHeader: rhs)
  }
}
