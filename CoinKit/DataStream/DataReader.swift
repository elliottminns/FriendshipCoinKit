//
//  DataReader.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public class DataReader {
  
  public enum Error: Swift.Error {
    case incorrectRead
    case tooManyBytes
  }
  
  public fileprivate(set) var position: UInt
  
  public var isEnded: Bool {
    return position >= data.count
  }
  
  fileprivate var pos: Data.Index {
    return data.startIndex + Int(position)
  }
  
  public let data: Data
  
  public init(data: Data) {
    self.data = data
    self.position = 0
  }
  
  public func next() -> UInt8 {
    let pos = position
    position = position + 1
    return data[Int(pos)]
  }
  
  public func move(positionBy delta: Int) {
    position = position.advanced(by: delta)
  }
  
  public func read<T: FixedWidthInteger>(endian: Endian) throws -> T {
    let size = Int(MemoryLayout<T>.size)
    guard data.endIndex >= pos + size else { throw Error.tooManyBytes }
    let d = data[pos ..< (pos + size)]
    position = position + UInt(size)
    return T.init(data: d, endian: endian)
  }
  
  public func readVariableInt() -> UInt {
    let value: UInt
    let size: Int
    let start = data.startIndex.advanced(by: Int(position))
    let first = data[start]
    if first < 0xfd {
      size = 1
      value = UInt(first)
    } else if first == 0xfd {
      size = 3
      let end = start.advanced(by: 1).advanced(by: size - 1)
      let bytes = data[start.advanced(by: 1) ..< end]
      let val = UInt16.init(data: bytes, endian: .little)
      value = UInt(val)
    } else if first == 0xfe {
      size = 5
      let end = start.advanced(by: 1).advanced(by: size - 1)
      let bytes = data[start.advanced(by: 1) ..< end]
      let val = UInt32(data: bytes, endian: .little)
      value = UInt(val)
    } else {
      size = 9
      let end = start.advanced(by: 1).advanced(by: size - 1)
      let bytes = data[start.advanced(by: 1) ..< end]
      let val = UInt64(data: bytes, endian: .little)
      value = UInt(val)
    }
    
    position = position.advanced(by: size)
    
    return value
  }
  
  public func read(bytes: UInt) throws -> Data {
    let start = pos
    let end = pos + Int(bytes)
    position = position + bytes
    
    if (end > data.endIndex) {
      throw Error.tooManyBytes
    }
    return Data(data[start ..< end])
  }
  
  public func readVariableBytes() throws -> Data {
    let startPosition = position
    let size = readVariableInt()
    do {
      return try read(bytes: size)
    } catch let error as Error where error == .tooManyBytes {
      position = startPosition
      throw error
    } catch let error {
      throw error
    }
  }
  
  public func readVector() throws -> [Data] {
    let count = readVariableInt()
    return try (0 ..< count).map { _ in
      return try readVariableBytes()
    }
  }
 }
