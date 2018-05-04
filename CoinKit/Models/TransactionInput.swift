//
//  TXInput.swift
//  CoinKit
//
//  Created by Elliott Minns on 02/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol TransactionInput {
  var hash: Data { get }
  
  var index: UInt32 { get }
  
  var script: Data { get }
  
  var sequence: UInt32 { get }
  
  init(hash: Data, index: UInt32, script: Data, sequence: UInt32)
}

extension TransactionInput {
  public func address(network: Network) -> Address? {
    return Address(inputScript: script, network: network)
  }
}
