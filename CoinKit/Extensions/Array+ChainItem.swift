//
//  Array+ChainItem.swift
//  CoinKit
//
//  Created by Elliott Minns on 06/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public extension Array where Element: ChainItem {
  
  public var isContinous: Bool {
    return self.enumerated().reduce(true) { (result, obj) -> Bool in
      guard obj.offset > 0 else { return true }
      guard result else { return false }
      
      let previous = self[obj.offset - 1]
      return obj.element.previousHash == previous.hash
    }
  }
  
}
