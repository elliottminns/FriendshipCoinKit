//
//  Signable.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol Signable {
  var publicKey: Data { get }
  
  func sign(_ hash: Data) throws -> ECSignature
  
  var network: Network { get }
}
