//
//  Ripemd160+Hash.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public extension Ripemd160 {
  
  public static func hash(message: Data) -> Data {
    var md = Ripemd160()
    md.update(data: message)
    return md.finalize()
  }
  
  public static func hash(message: String) -> Data {
    return Ripemd160.hash(message: message.data(using: .utf8)!)
  }
}
