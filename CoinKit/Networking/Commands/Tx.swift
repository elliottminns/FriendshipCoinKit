//
//  Transaction.swift
//  CoinKit
//
//  Created by Elliott Minns on 02/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct Tx<T: CoinKit.Transaction>: Command {
    
    let name: String = "tx"
    
    let transaction: T
    
    init(transaction: T) {
      self.transaction = transaction
    }
    
    func encode() -> Data {
      return transaction.toData()
    }
  }
}
