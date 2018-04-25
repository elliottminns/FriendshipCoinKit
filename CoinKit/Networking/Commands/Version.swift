//
//  Version.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension UInt64 {
  static var pseudoRandom: UInt64 {
    return [arc4random(), arc4random()].reduce(0, { (res, rando) -> UInt64 in
      return (res << 32) + UInt64(rando)
    })
  }
}

extension UInt32 {
  
  public func IPv4String() -> String {
    
    let ip = self
    
    let byte1 = UInt8(ip & 0xff)
    let byte2 = UInt8((ip>>8) & 0xff)
    let byte3 = UInt8((ip>>16) & 0xff)
    let byte4 = UInt8((ip>>24) & 0xff)
    
    return "\(byte1).\(byte2).\(byte3).\(byte4)"
  }
}

extension String {
  public func IPv4Int() -> UInt32? {
    let bytes = self.split(separator: ".").compactMap { UInt8($0) }
    guard bytes.count == 4 else { return nil }
    
    let value: UInt32 = bytes.reduce(0) { (value, byte) -> UInt32 in
      let hm = value << 8
      return hm + UInt32(byte)
    }
    
    return value
    
  }
}

struct CommandType {
  struct Version: Command {
    let name: String = "version"
    
    let version: UInt32
    
    let userAgent: String
    
    let startHeight: Int
    
    let relay: Bool
    
    let peerAddress: String
    
    let port: UInt16
    
    let nonce: UInt64
    
    init(version: UInt32, userAgent: String,
         startHeight: Int = 0, relay: Bool,
         peerAddress: String, port: UInt16) {
      self.version = version
      self.userAgent = "/iOS:11.3.1/CointKit:1.0.0/"
      self.startHeight = startHeight
      self.relay = relay
      self.peerAddress = peerAddress
      self.port = port
      self.nonce = UInt64.pseudoRandom
    }
    
    func encode() -> Data {
      let timestamp = Int(Date().timeIntervalSince1970)
      var data = Data()
      data.append(bytesFrom: self.version, endian: .little)
      data.append(bytesFrom: UInt64(0), endian: .little)
      data.append(bytesFrom: UInt64(timestamp), endian: .little)
      
      data.append(bytesFrom: UInt64(1), endian: .little)
      data.append(bytesFrom: UInt64(0), endian: .little)
      data.append(bytesFrom: UInt16(0), endian: .little)
      data.append(bytesFrom: UInt16.max, endian: .little)
      data.append(bytesFrom: peerAddress.IPv4Int()!, endian: .big)
      data.append(bytesFrom: self.port, endian: .big)
      
      data.append(bytesFrom: UInt64(0), endian: .little)
      data.append(bytesFrom: UInt64(0), endian: .little)
      data.append(bytesFrom: UInt16(0), endian: .little)
      data.append(bytesFrom: UInt16.max, endian: .little)
      data.append(bytesFrom: UInt32(0), endian: .little)
      data.append(bytesFrom: UInt16(0), endian: .little)
      data.append(bytesFrom: nonce, endian: .little)
      data.append(variable: userAgent.data(using: .ascii)!, endian: .little)
      data.append(bytesFrom: UInt32(startHeight), endian: .little)
      data.append(bool: relay)
      return data
    }
  }
}
