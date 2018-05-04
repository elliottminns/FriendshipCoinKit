//
//  TransactionOutput.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct TransactionOutput {
  public let amount: UInt64
  
  public let script: Data
  
  public static let blank: TransactionOutput = TransactionOutput(amount: UInt64.max)
  
  public init(amount: UInt64, script: Data = Data()) {
    self.amount = amount
    self.script = script
  }
 
  public func address(network: Network) -> Address? {
    return Address(outputScript: script, network: network)
  }
}

