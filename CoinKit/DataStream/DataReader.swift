//
//  DataReader.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class DataReader {
  
  fileprivate var position: UInt
  
  let data: Data
  
  init(data: Data) {
    self.data = data
    self.position = 0
  }
  
  func next() -> UInt8 {
    let pos = position
    position = position + 1
    return data[Int(pos)]
  }
  
  func move(positionBy delta: Int) {
    position = position.advanced(by: delta)
  }
  
  func read<T: FixedWidthInteger>(endian: Endian) -> T {
    let size = UInt(MemoryLayout<T>.size)
    let d = data[position ..< (position + size)]
    position = position + size
    return T.init(data: d, endian: endian)
  }
  
  func readVariableInt() -> UInt {
    let value: UInt
    let size: Int
    let first = data[data.startIndex.advanced(by: Int(position))]
    if first < 0xfd {
      size = 1
      value = UInt(first)
    } else if first == 0xfd {
      size = 3
      let bytes = data[data.startIndex + 1 ..< data.startIndex + 3]
      let val = UInt16.init(data: bytes, endian: .little)
      value = UInt(val)
    } else if first == 0xfe {
      size = 5
      let val = UInt32(data: data[data.startIndex + 1 ..< data.startIndex + 5], endian: .little)
      value = UInt(val)
    } else {
      size = 9
      let val = UInt64(data: data[data.startIndex + 1 ..< data.startIndex + 9], endian: .little)
      value = UInt(val)
    }
    
    position = position.advanced(by: size)
    
    return value
  }
  
  func read(bytes: UInt) -> Data {
    let start = UInt(data.startIndex) + position
    let end = UInt(data.startIndex) + position + bytes
    position = end
    return Data(data[start ..< end])
  }
  
  func readVariableBytes() -> Data {
    let size = readVariableInt()
    return read(bytes: size)
  }
  
  func readVector() -> [Data] {
    let count = readVariableInt()
    return (0 ..< count).map { _ in
      return readVariableBytes()
    }
  }
 }
