//
//  NeoScrypt.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

@_silgen_name("neoscrypt") private func c_neoscrypt(_ password: UnsafePointer<UInt8>, output: UnsafeMutablePointer<UInt8>, profile: UInt32)


public class NeoScrypt: HashingAlgorithm {
  
  public init() {
    
  }
  
  public func hash(data: Data) -> Data {
    var result = Data(count: 32)
    data.withUnsafeBytes { bytes  in
      result.withUnsafeMutableBytes { mutableBytes in
        c_neoscrypt(bytes, output: mutableBytes, profile: 0)
      }
    }
    
    return result
  }
}
