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
  public func hash(blockHeader: BlockHeader) -> Data {
    var data = Data()
    data.append(bytesFrom: blockHeader.version, endian: .little)
    data.append(Data(blockHeader.prevHash.reversed()))
    data.append(Data(blockHeader.merkleRoot.reversed()))
    data.append(bytesFrom: blockHeader.timestamp, endian: .little)
    data.append(bytesFrom: blockHeader.bits, endian: .little)
    data.append(bytesFrom: blockHeader.nonce, endian: .little)
    
    return hash(data: data)
  }
}
