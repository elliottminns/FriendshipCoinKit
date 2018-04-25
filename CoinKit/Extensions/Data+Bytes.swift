//
//  Data+Bytes.swift
//  CoinKit
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public enum Endian {
  case big
  case little
}

public extension FixedWidthInteger {
  var bytes: [UInt8] {
    var bigEndian = self.bigEndian
    let count = MemoryLayout<Self>.size
    let bytePtr = withUnsafePointer(to: &bigEndian) {
      $0.withMemoryRebound(to: UInt8.self, capacity: count) {
        UnsafeBufferPointer(start: $0, count: count)
      }
    }
    let byteArray = Array(bytePtr)
    return byteArray
  }
  
  func toData(endian: Endian) -> Data {
    let bytes = endian == .little ? self.bytes.reversed() : self.bytes
    return Data.init(bytes: bytes)
  }
  
  init(bytes: [UInt8], endian: Endian = .big) {
    let data = Data(bytes: bytes)
    self.init(data: data, endian: endian)
  }
  
  init(data: Data, endian: Endian = .big) {
    switch endian {
    case .big: self.init(bigEndian: data.withUnsafeBytes { $0.pointee })
    case .little: self.init(littleEndian: data.withUnsafeBytes { $0.pointee })
    }
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
