//
//  HashingAlgorithm.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol HashingAlgorithm {
  func hash(data: Data) -> Data
}

public extension HashingAlgorithm {
  
  public func hash(version: Int32, previousHash: Data, merkleRoot: Data,
                   timestamp: UInt32, bits: UInt32, nonce: UInt32) -> Data {
    var data = Data()
    data.append(bytesFrom: version, endian: .little)
    data.append(previousHash)
    data.append(merkleRoot)
    data.append(bytesFrom: timestamp, endian: .little)
    data.append(bytesFrom: bits, endian: .little)
    data.append(bytesFrom: nonce, endian: .little)
    
    return hash(data: data)
  }
  
  public func hash(blockHeader: BlockHeader) -> Data {
    return hash(version: blockHeader.version,
                previousHash: blockHeader.prevHash,
                merkleRoot: blockHeader.merkleRoot,
                timestamp: blockHeader.timestamp,
                bits: blockHeader.bits,
                nonce: blockHeader.nonce)
  }
}
