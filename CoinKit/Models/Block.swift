//
//  Block.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol Block: ChainItem {
  
  associatedtype TransactionType: Transaction
  
  var hash: Data { get }
  
  var data: Data { get }
  
  var previousHash: Data { get }
  
  var merkleRoot: Data { get }
  
  var version: Int32 { get }
  
  var timestamp: UInt32 { get }
  
  var nonce: UInt32 { get }
  
  var bits: UInt32 { get }
  
  var transactions: [TransactionType] { get }
  
  init(data: Data) throws
  
  init(data: Data, hash: Data) throws
}

extension Block {
  public var hashValue: Int { return hash.hashValue }
  
  public static func ==<T: Block>(lhs: Self, rhs: T) -> Bool {
    return lhs.hash == rhs.hash
  }
}

extension Block {
  public var header: BlockHeader {
    return BlockHeader(hash: hash, version: version, prevHash: previousHash, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, transactionCount: UInt16(transactions.count))
  }
}
