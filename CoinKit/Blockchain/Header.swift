//
//  Header.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct BlockHeader {
  
  public let hash: Data
  
  public let version: Int32
  
  public let prevHash: Data
  
  public let merkleRoot: Data
  
  public let bits: UInt32
  
  public let nonce: UInt32
  
  public let timestamp: UInt32
  
  public let transactionCount: UInt16
  
  public init(data: Data, hashingAlgorithm: HashingAlgorithm) throws {
    let reader = DataReader(data: data)
    let version: Int32 = try reader.read(endian: .little)
    let previousHash: Data = Data(try reader.read(bytes: 32))
    let merkleRoot: Data = Data(try reader.read(bytes: 32))
    let timestamp: UInt32 = try reader.read(endian: .little)
    let bits: UInt32 = try reader.read(endian: .little)
    let nonce: UInt32 = try reader.read(endian: .little)
    
    self.init(version: version, prevHash: previousHash, merkleRoot: merkleRoot,
              bits: bits, nonce: nonce, timestamp: timestamp,
              transactionCount: 0, hashingAlgorithm: hashingAlgorithm)
  }
  
  public init(version: Int32, prevHash: Data, merkleRoot: Data, bits: UInt32,
              nonce: UInt32, timestamp: UInt32, transactionCount: UInt16, hashingAlgorithm: HashingAlgorithm) {
    let hash = hashingAlgorithm.hash(version: version, previousHash: prevHash,
                                     merkleRoot: merkleRoot,
                                     timestamp: timestamp,
                                     bits: bits, nonce: nonce)
    
    self.init(hash: hash, version: version, prevHash: prevHash, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, transactionCount: transactionCount)
  }
  
  public init(hash: Data, version: Int32, prevHash: Data, merkleRoot: Data,
              timestamp: UInt32, bits: UInt32, nonce: UInt32,
              transactionCount: UInt16) {
    self.version = version
    self.prevHash = prevHash
    self.merkleRoot = merkleRoot
    self.bits = bits
    self.nonce = nonce
    self.timestamp = timestamp
    self.transactionCount = transactionCount
    self.hash = hash
  }
  
  func encoded() -> Data {
    var data = Data()
    data.append(bytesFrom: version, endian: .little)
    data.append(prevHash)
    data.append(merkleRoot)
    data.append(bytesFrom: timestamp, endian: .little)
    data.append(bytesFrom: bits, endian: .little)
    data.append(bytesFrom: nonce, endian: .little)
    return data
  }
}

extension BlockHeader: Equatable {
  public static func ==(lhs: BlockHeader, rhs: BlockHeader) -> Bool {
    return lhs.hash == rhs.hash
  }
}

extension BlockHeader: Hashable {
  public var hashValue: Int { return hash.hashValue }
}

extension BlockHeader: ChainItem {
  public var previousHash: Data {
    return prevHash
  }
}
