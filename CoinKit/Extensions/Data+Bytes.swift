//
//  Data+Bytes.swift
//  CoinKit
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension UInt32 {
  var bytes: [UInt8] {
    var bigEndian = self.bigEndian
    let count = MemoryLayout<UInt32>.size
    let bytePtr = withUnsafePointer(to: &bigEndian) {
      $0.withMemoryRebound(to: UInt8.self, capacity: count) {
        UnsafeBufferPointer(start: $0, count: count)
      }
    }
    let byteArray = Array(bytePtr)
    return byteArray
  }
  
  init(bytes: [UInt8]) {
    let data = Data(bytes: bytes)
    self.init(data: data)
  }
  
  init(data: Data) {
    self = UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
  }
}

extension Data {
  
  var bytes: [UInt8] {
    return (startIndex ..< endIndex).map { self[$0] }
  }
  
  mutating func write(bytes: UInt32, at index: Int) {
    let byteArray = bytes.bytes
    byteArray.enumerated().forEach { val in
      write(byte: val.element, at: index + val.offset)
    }
  }
  
  mutating func write(byte: UInt8, at index: Int) {
    self[index] = byte
  }
}
