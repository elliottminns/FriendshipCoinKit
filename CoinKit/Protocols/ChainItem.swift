//
//  ChainItem.swift
//  CoinKit
//
//  Created by Elliott Minns on 06/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol ChainItem: Hashable {
  var hash: Data { get }
  
  var previousHash: Data { get }
}

public extension ChainItem {
  var hashValue: Int { return hash.hashValue }
}
