//
//  Blockchain.swift
//  CoinKit
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct BrokenChainError<T>: Swift.Error {
  public let a: T
  public let b: T
}

public struct BrokenChainBlockError<T: Block>: Swift.Error {
  public let previous: T
  public let current: T
}

open class Blockchain<T: Block> {
  
  public struct BrokenChainError<T>: Swift.Error {
    public let a: T
    public let b: T
  }

  
  public enum Error: Swift.Error {
    case chainBroken
    case notFound
  }
  
  public let genesis: T
  
  public let hashingAlgorithm: HashingAlgorithm
  
  let store: BlockStore<T>
  
  public fileprivate(set) var headers: [BlockHeader] = []
  
  public fileprivate(set) var blocks: [T] {
    set {
      mainChain = newValue
    }
    
    get {
      return mainChain
    }
  }
  
  public fileprivate(set) var mainChain: [T] = []
  
  public fileprivate(set) var orphans: [[T]] = []
  
  public fileprivate(set) var forks: [[T]] = []
  
  public var tip: T {
    return mainChain.last ?? store.getTip() ?? genesis
  }
  
  public init(genesis: T, hashingAlgorithm: HashingAlgorithm) {
    self.genesis = genesis
    self.hashingAlgorithm = hashingAlgorithm
    self.store = BlockStore(genesis: genesis, hashingAlgorithm: hashingAlgorithm)
    loadStored()
  }
  
  func loadStored() {
    if let tip = store.getTip() {
      mainChain.append(tip)
      headers.append(tip.header)
    }
  }
  
  public func add(block: T) {
    store.write(block: block)
    mainChain.append(block)
    checkOrphans()
  }
  
  public func add(blocks: [T]) {
    guard blocks.count > 0 else { return }
    
    let first = blocks[0]
    
    guard let parent = store.block(for: first.previousHash) else {
      if blocks.isContinous {
        self.add(orphans: blocks)
      } else {
        
      }
      return
    }
    
    if parent != tip {
      store.set(best: parent.data)
      while mainChain.count > 0 && mainChain.last != parent {
        _ = mainChain.popLast()
      }
    }
    
    if blocks.isContinous {
      blocks.forEach { block in
        store.write(block: block)
        mainChain.append(block)
      }
      checkOrphans()
    } else {
      blocks.forEach(add(block:))
    }
  }
  
  public func add(orphans: [T]) {
    self.orphans.append(orphans)
  }
  
  public func checkOrphans() {
    let tip = self.tip
    let matching = orphans.filter { orphanChain in
      guard let first = orphanChain.first else { return false }
      return first.previousHash == tip.hash
    }
    
    let longest = matching.max { (a, b) -> Bool in
      return a.count > b.count
    }
    
    guard let longestChain = longest else { return }
    self.orphans = orphans.filter { chain in
      guard let first = chain.first else { return false }
      return first.previousHash != tip.hash
    }
    self.add(blocks: longestChain)
  }
  
  public func block(at index: Int) -> T? {
    if index < 0 {
      return self.block(fromTip: -index)
    } else if index == 0 {
      return self.genesis
    } else {
      fatalError("Not yet implemented")
    }
  }
  
  fileprivate func block(fromTip number: Int) -> T? {
    let tip = self.tip
    return block(from: tip, by: number)
  }
  
  func block(from block: T, by number: Int) -> T? {
    guard block != self.genesis else { return nil }
    guard number != 0 else { return block }
    guard let previous = self.store.block(for: block.previousHash) else { return nil }
    return self.block(from: previous, by: number - 1)
  }
  
  public func header(at index: Int) -> BlockHeader? {
    return nil
    /*
    if index >= 0 {
      return store.header(at: index)
    } else {
      return store.header(at: self.store.getHeight() + index)
    }*/
  }
  
  public func block(with hash: Data) -> T? {
    return store.block(for: hash)
  }
  
  public func moveTop(to hash: Data) throws {
    guard let block = self.block(with: hash) else { throw Error.notFound }
    var currentTop = self.tip
    var count = 0
    while currentTop != block && currentTop != genesis {
      guard let next = self.block(with: currentTop.previousHash) else {
        throw Error.notFound
      }
      count = count + 1
      currentTop = next
    }
    
    self.store.set(height: count)
    self.store.set(best: hash)
  }
  
  func check(blocks: [T], from: T) throws {
   try check(blocks: [from] + blocks)
  }
  
  func check(blocks: [T]) throws {
    let trimmed = try blocks.enumerated().filter { item -> Bool in
      guard item.offset > 0 else { return true }
      
      let index = item.offset
      let block = item.element
      let previous = blocks[index - 1]
      let previousHash = previous.hash
      let inline = previousHash == block.previousHash
      if !inline { throw BrokenChainError(a: previous, b: block) }
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
