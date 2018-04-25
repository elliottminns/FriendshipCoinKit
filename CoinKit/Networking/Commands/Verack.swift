//
//  Verack.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension CommandType {
  struct Verack: Command {
    
    let name: String = "verack"
    
    func encode() -> Data {
      return Data()
    }
  }
}
