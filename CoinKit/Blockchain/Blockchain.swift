//
//  Blockchain.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct BrokenChainError: Swift.Error {
  public let a: BlockHeader
  public let b: BlockHeader
}

public struct BrokenChainBlockError<T: Block>: Swift.Error {
  public let previous: T
  public let current: T
}

open class Blockchain<T: Block> {
  
  enum Error: Swift.Error {
    case chainBroken
  }
  
  public let genesis: T
  
  public let hashingAlgorithm: HashingAlgorithm
  
  let store: BlockStore<T>
  
  public fileprivate(set) var headers: [BlockHeader] = []
  
  public fileprivate(set) var blocks: [T] = []
  
  public var tip: BlockHeader {
    return store.getTop()?.header ?? genesis.header
  }
  
  public var top: T {
    return store.getTop() ?? genesis
  }
  
  public init(genesis: T, hashingAlgorithm: HashingAlgorithm) {
    self.genesis = genesis
    self.hashingAlgorithm = hashingAlgorithm
    self.store = BlockStore(genesis: genesis, hashingAlgorithm: hashingAlgorithm)
    loadStored()
  }
  
  func loadStored() {
    if let header = store.getTop()?.header {
      headers.append(header)
    }
  }
  
  public func missingBlocks() -> [BlockHeader] {
    return store.getMissingBlocks()
  }
  
  public func missingBlocks(callback: @escaping ([BlockHeader]) -> Void) {
    DispatchQueue.global().async {
      let blocks = self.missingBlocks()
      DispatchQueue.main.async {
        return callback(blocks)
      }
    }
  }
  
  public func add(headers: [BlockHeader]) throws {
    let last = tip
    do {
      try check(headers: [last] + headers)
      let start = store.getHeight() + 1
      self.headers = headers
      /*
      store.write(headers: headers.enumerated().map { obj -> (index: Int, header: BlockHeader) in
        return (index: obj.offset + start, header: obj.element)
      })
 */
    } catch let error {
      guard last != genesis.header else { throw error }
      self.removeTip()
      throw error
    }
  }
  
  public func removeTip() {
    store.removeTip()
  }
  
  public func add(block: T) {
    store.write(block: block)
  }
  
  public func add(blocks: [T]) throws {
    let last = top
    try check(blocks: blocks, from: last)
    blocks.forEach { store.write(block: $0) }
  }
  
  public func header(at index: Int) -> BlockHeader? {
    return nil
    /*
    if index >= 0 {
      return store.header(at: index)
    } else {
      return store.header(at: self.store.getHeight() + index)
    }
    */
  }
  
  public func block(with hash: Data) -> T? {
    return store.block(for: hash)
  }
  
  func check(blocks: [T], from: T) throws {
    let trimmed = blocks.enumerated().filter { (item) -> Bool in
      let index = item.offset
      let block = item.element
      let previous = item.offset > 0 ? blocks[index - 1] : from
      let previousHash = previous.hash
      let inline = previousHash == block.previousHash
      return inline
      }.map { $0.element }
    if trimmed.count != blocks.count {
      throw Error.chainBroken
    }
  }
  
  func check(headers: [BlockHeader]) throws {
    let fine = try headers.enumerated().reduce(true) { (result, obj) -> Bool in
      let index = obj.offset
      guard index > 0 else { return true }
      let header = obj.element
      let previous = headers[index - 1]
      let previousHash = previous.hash
      let inline = previousHash == header.prevHash
      if !inline {
        throw BrokenChainError(a: previous, b: header)
      }
      return inline
    }
    
    if (!fine) { throw Error.chainBroken }
  }
}
