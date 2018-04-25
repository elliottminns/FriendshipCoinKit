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

public protocol P2PNetworkDelegate: class {
  func network(_ network: P2PNetwork, didConnectToPeer peer: Peer)
  func network(_ network: P2PNetwork, didDisconnectFromPeer peer: Peer)
}

public class P2PNetwork {
 
  public let parameters: Parameters
  
  public let options: Options
  
  public weak var delegate: P2PNetworkDelegate?
  
  var connecting: Bool = false
  
  fileprivate(set) public var peers: [Peer] = []
  
  var connections: [String: Connection] = [:]
  
  fileprivate var messageHandlers: [MessageHandler] = [PingHandler(), VersionHandler()]
  
  public init(parameters: Parameters, options: Options = Options(), delegate: P2PNetworkDelegate? = nil) {
    self.parameters = parameters
    self.options = options
    self.delegate = delegate
  }
  
  public func connect() {
    connecting = true
    fillPeers()
  }
  
  public func add(messageHandler handler: MessageHandler) {
    messageHandlers.append(handler)
  }
 
  public func send() {
    
  }
  
  public func createHeaderStream() {
    
  }
  
  public func createBlockStream() {
  }
  
  public func getHeaders(locators: [BlockHeader], stop: BlockHeader? = nil) {
    let lcs = locators.map { $0.hash }
    let peer = peers.random()
    peer.getHeaders(locator: lcs, stop: stop?.hash) { (result, peer) in
      switch result {
      case .failure(_): self.getHeaders(locators: locators, stop: stop)
      case .success(_): break
      }
    }
  }
  
  public func get(block hash: String, callback: @escaping () -> Void) {
//    let peer = peers.random()
//    peer.get(block: hash, callback: callback) { _ in
//    }
  }
  
  public func get(transactions: [String], callback: @escaping () -> Void) {
    let peer = peers.random()
    peer.get(transactions: transactions, callback: callback)
  }
  
  public func close() {
    
  }
}

public extension P2PNetwork {
  
  public struct Parameters {
    public let magic: UInt32
    
    public let defaultPort: UInt32
    
    public let dnsSeeds: [String]
    
    public let staticNodes: [String]
    
    public init(magic: UInt32, defaultPort: UInt32, dnsSeeds: [String],
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

extension P2PNetwork {
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
        self.connectStream(address: address)
      }
    }
  }
  
  func connectStaticPeer() {
    let peers = parameters.staticNodes
    let address = peers.random()
    connectStream(address: address)
  }
  
  func connectStream(address: String) {
    self.connectStream(address: address, port: parameters.defaultPort)
  }
  
  func connectStream(address: String, port: UInt32) {
    guard connections[address] == nil else { return }
    let connection = Connection(address: address, port: port)
    connections[address] = connection
    connection.connect {
      let peer = Peer(connection: connection, params: Peer.Params(magic: self.parameters.magic), delegate: self)
      peer.sendVersion()
      self.peers.append(peer)
      self.delegate?.network(self, didConnectToPeer: peer)
    }
  }
}

extension P2PNetwork: PeerDelegate {
  func peer(_ peer: Peer, didSendMessage message: Message) {
    print("Recv: \(message.type)")
    let handlers = messageHandlers.filter { $0.handles(message: message) }
    handlers.forEach { $0.handle(message: message, from: peer) }
  }
  
  func peerDidDisconnect(_ peer: Peer) {
    self.connections[peer.address] = nil
    self.peers = peers.filter {
      return peer.address != $0.address
    }
  }
}
