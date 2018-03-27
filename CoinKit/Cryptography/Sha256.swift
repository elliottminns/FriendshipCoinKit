//
//  Sha256.swift
//  CoinKit
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import CommonCrypto

extension Array where Element == UInt8 {
  public var sha256: [UInt8] {
    let bytes = self
    
    let mutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
    
    CC_SHA256(bytes, CC_LONG(bytes.count), mutablePointer)
    
    let mutableBufferPointer = UnsafeMutableBufferPointer<UInt8>.init(start: mutablePointer, count: Int(CC_SHA256_DIGEST_LENGTH))
    let sha256Data = Data(buffer: mutableBufferPointer)
    
    mutablePointer.deallocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
    
    return sha256Data.bytes
  }
}
