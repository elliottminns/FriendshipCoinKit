//
//  LevelUp.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class BlockStore<T: Block> {
  let db: Store
  
  let queue: DispatchQueue = DispatchQueue(label: "com.block.chain.queue")
  
  let hashingAlgorithm: HashingAlgorithm
  /*
  init(genesis: BlockHeader, hashingAlgorithm: HashingAlgorithm) {
    db = Store(dbName: "block.chain")
    self.hashingAlgorithm = hashingAlgorithm
    
    if db.get("top").isEmpty {
      db.put("top", value: "0")
      write(headers: [(height: 0 , header: genesis)])
    }
  }
  */
  init(genesis: T, hashingAlgorithm: HashingAlgorithm) {
    db = Store(dbName: "block.chain")
    self.hashingAlgorithm = hashingAlgorithm
    
    if db.get("top").isEmpty {
      db.put("top", value: "0")
      write(block: genesis)
    }
  }
  /*
  func write(headers: [(height: Int, header: BlockHeader)]) {
    queue.async {
      headers.forEach { header in
        let encoded = self.encode(height: header.height, header: header.header, next: Data(count: 32))
        let key = header.header.hash.base64EncodedString()
        let isNew = self.db.get(key).isEmpty
        
        self.db.put(key, value: encoded.hexEncodedString())
        self.db.put("\(header.height)", value: key)
        
        if isNew {
          let count = Int(self.db.get("headercount")) ?? 0
          self.db.put("headercount", value: "\(count + 1)")
          print("Headercount: \(count)")
        }
        
        let height = Int(self.db.get("top")) ?? 0
        if height < header.height {
          self.db.put("top", value: "\(header.height)")
        }
      }
    }
  }
  */
  /*
  func encode(height: Int, header: BlockHeader, next: Data) -> Data {
    var data = Data()
    data.append(bytesFrom: UInt32(height), endian: .little)
    data.append(header.encoded())
    data.append(next)
    return data
  }
  
  func decode(data: Data) throws -> (height: UInt32, header: BlockHeader, next: Data) {
    let headerHeight: UInt32 = UInt32(bytes: data[data.startIndex ..< data.startIndex + 4].bytes, endian: .little)
    let headerData = Data(data[data.startIndex + 4 ..< data.endIndex - 32])
    let header = try BlockHeader(data: headerData, hashingAlgorithm: hashingAlgorithm)
    let next = Data(data[data.endIndex - 32 ..< data.endIndex])
    
    return (height: headerHeight, header: header, next: next)
  }
  */
  func write(block: T) {
    queue.async {
      let key = block.hash.base64EncodedString()
      let exists = !self.db.get(key).isEmpty
      self.db.put(key, value: block.data.base64EncodedString())
      self.db.put("best", value: key)
      if !exists {
        let count = Int(self.db.get("blockcount")) ?? 0
        self.db.put("\(count)", value: key)
        self.db.put("blockcount", value: "\(count + 1)")
      }
    }
  }
  
  func getHeight() -> Int {
    return queue.sync {
      return Int(self.db.get("blockcount")) ?? 0
    }
  }
  
  func set(height: Int) {
    return queue.sync {
      self.db.put("top", value: "\(height)")
    }
  }
  
  func getTop() -> T? {
    return queue.sync {
      let count = Int(self.db.get("blockcount")) ?? 1
      let key = self.db.get("\(count - 1)")
      let str = self.db.get(key)
      guard let data = Data(base64Encoded: str) else { return nil }
      let block = try? T.init(data: data)
      return block
    }
    /*
    let height = self.getHeight()
    return queue.sync {
      let key = self.db.get("\(height)")
      guard let data = self.db.get(key).hexadecimal() else { return nil }
      
      guard let decoded = try? decode(data: data) else {
        self.db.put("top", value: "0")
        return nil
      }
      
      guard decoded.height == height else {
        // Scorched earth reset the data. Should recheck the chain.
        self.db.put("top", value: "0")
        return nil
      }

      return decoded
    }*/
  }
  
  func block(for hash: Data) -> T? {
    let key = hash.base64EncodedString()
    let dataStr = queue.sync { return self.db.get(key) }
    guard let data = Data(base64Encoded: dataStr), data.count > 0 else {
      return nil
    }
    let block = try? T.init(data: data)
    return block
  }
  /*
  func header(at height: Int) -> BlockHeader? {
    let key = self.db.get("\(height)")
    guard !key.isEmpty else { return nil }
    return header(for: key)
  }
  
  func header(for key: String) -> BlockHeader? {
    let dataStr = self.db.get(key)
    guard !dataStr.isEmpty, let data = dataStr.hexadecimal() else { return nil }
    return try? decode(data: data).header
  }
  
  func header(for hash: Data) -> BlockHeader? {
    let key = hash.base64EncodedString()
    return header(for: key)
  }
  */
  func getMissingBlocks() -> [BlockHeader] {
    return []
    /*
    guard let start = self.getTop() else { return [] }
    
    let blockCount = self.queue.sync {
      return Int(self.db.get("blockcount")) ?? 0
    }
    
    let headerCount = self.queue.sync {
      return Int(self.db.get("headercount")) ?? 0
    }
    guard blockCount != headerCount else { return [] }
    
    var blocks: [BlockHeader] = []
    
    let checker = { (header: BlockHeader) -> BlockHeader? in
      let blockKey = header.hash.hexEncodedString()
      let missing = self.queue.sync {
        return self.db.get(blockKey).isEmpty
      }
      if missing { blocks.append(header) }
      
      let nextHash = header.prevHash
      return self.header(for: nextHash)
    }
    
    var head: BlockHeader? = start
   
    while let header = head, blocks.count + blockCount != headerCount {
      head = checker(header)
    }
    
    if blocks.count == 0 {
      self.queue.async {
        self.db.put("blockcount", value: "\(headerCount)")
      }
    }
    
    return blocks*/
  }
  
  func removeTip() {
    let height = self.getHeight()
    guard let top = self.getTop() else { return }
    queue.sync {
      let key = top.hash.hexEncodedString()
      self.db.delete(key)
      
      let count = Int(self.db.get("blockcount")) ?? 1
      self.db.put("blockcount", value: "\(count - 1)")
      
      print("Delete: \(count)")
    }
    
    self.set(height: height - 1)
  }
}
