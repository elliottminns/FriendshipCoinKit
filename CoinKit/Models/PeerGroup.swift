//
//  PeerGroup.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

extension Array {
  func random() -> Element {
    let index = arc4random_uniform(UInt32(count))
    return self[Int(index)]
  }
}

public protocol PeerGroupDelegate: class {
  func peer(group: PeerGroup, didConnectToPeer peer: Peer)
}

public class PeerGroup {
 
  public let parameters: Parameters
  
  public let options: Options
  
  weak var delegate: PeerGroupDelegate?
  
  var connecting: Bool = false
  
  var peers: [Peer] = []
  
  public init(parameters: Parameters, options: Options = Options(), delegate: PeerGroupDelegate?) {
    self.parameters = parameters
    self.options = options
    self.delegate = delegate
  }
  
  public func connect() {
    connecting = true
    fillPeers()
  }
  
 
  public func send() {
    
  }
  
  public func createHeaderStream() {
    
  }
  
  public func createBlockStream() {
    
  }
  
  public func get(blocks hashes: [String], callback: @escaping () -> Void) {
    
  }
  
  public func get(transactions blockHash: String, callback: @escaping () -> Void) {
    
  }
  
  public func close() {
    
  }
}

public extension PeerGroup {
  
  public struct Parameters {
    public let magic: Int32
    
    public let defaultPort: Int32
    
    public let dnsSeeds: [String]
    
    public let staticNodes: [String]
    
    public init(magic: Int32, defaultPort: Int32, dnsSeeds: [String],
                staticNodes: [String]) {
      self.magic = magic
      self.defaultPort = defaultPort
      self.dnsSeeds = dnsSeeds
      self.staticNodes = staticNodes
    }
  }
  
  public struct Options {
    public let numberPeers: UInt8
    
    public let hardLimit: Bool
    
    public let connectTimeout: Int
    
    public let peerOptions: Peer.Options
    
    public init(numberPeers: UInt8 = 8, hardLimit: Bool = false,
                connectTimeout: Int = 5000,
                peerOptions: Peer.Options = Peer.Options()) {
      self.numberPeers = numberPeers
      self.hardLimit = hardLimit
      self.connectTimeout = connectTimeout
      self.peerOptions = peerOptions
    }
  }
}

extension PeerGroup {
  func fillPeers() {
    let remaining = Int(options.numberPeers) - peers.count
    (0 ..< remaining).forEach { _ in connectPeer() }
  }
  
  func connectPeer() {
    if parameters.dnsSeeds.count > 0 {
      connectDNSPeer()
    }
    if parameters.staticNodes.count > 0 {
      connectStaticPeer()
    }
  }
  
  func connectDNSPeer() {
    let seeds = parameters.dnsSeeds
    let seed = seeds.random()
    
    let dns = DNSResolver(hostName: seed)
    dns.resolve { (result) in
      if case let .success(addresses) = result {
        let address = addresses.random()
        self.connectTCP(address: address)
      }
    }
  }
  
  func connectStaticPeer() {
    let peers = parameters.staticNodes
    let address = peers.random()
    connectTCP(address: address)
  }
  
  func connectTCP(address: String, port: Int32? = nil) {
    let p = port ?? parameters.defaultPort
    let client = TCPClient(address: address, port: p)
    let timeout = options.connectTimeout
    DispatchQueue.global().async {
      switch client.connect(timeout: timeout) {
      case .success(_):
        let peer = Peer(socket: client, params: Peer.Params())
        self.peers.append(peer)
        self.delegate?.peer(group: self, didConnectToPeer: peer)
      case .failure(_): break
      }
    }
  }
}
