//
//  Blockchain.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

open class Blockchain {
  
  public let genesis: BlockHeader
  
  public fileprivate(set) var blocks: [BlockHeader] = []
  
  public var tip: BlockHeader {
    return blocks.last ?? genesis
  }
  
  public init(genesis: BlockHeader) {
    self.genesis = genesis
  }
}
