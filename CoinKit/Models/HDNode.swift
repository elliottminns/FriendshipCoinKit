//
//  HDNode.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct HDNode {
  
  init(seed: Data) {
    
  }
  
  init(seedHex: String) {
    
  }
  
  func derive(path: String) -> HDNode {
    return self
  }
  
  func deriveHardened(_ index: Int) -> HDNode {
    return self
  }
  
  func derive(_ index: Int) -> HDNode {
    return self
  }
}
