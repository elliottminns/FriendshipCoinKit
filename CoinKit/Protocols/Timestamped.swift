//
//  Timestamped.swift
//  CoinKit
//
//  Created by Elliott Minns on 04/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public protocol Timestamped {
  var timestamp: UInt32 { get }
}
extension Timestamped {
  public var date: Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp))
  }
}
