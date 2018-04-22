//
//  TransactionOutput.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension Transaction {
  struct Output {
    let amount: UInt64
    
    let script: Data
    
    static let blank: Output = Output(amount: UInt64.max)
    
    init(amount: UInt64, script: Data = Data()) {
      self.amount = amount
      self.script = script
    }
  }
}
