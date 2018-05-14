//
//  PeerGroup.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public typealias Magic = UInt32

extension Array {
  func random() -> Element {
    let index = arc4random_uniform(UInt32(count))
    return self[Int(index)]
  }
}

public protocol P2PNetworkDelegate: class {
  func network<T: Block>(_ network: P2PNetwork<T>, didConnectToPeer peer: Peer)
  func network<T: Block>(_ network: P2PNetwork<T>, didDisconnectFromPeer peer: Peer)
}

public class P2PNetwork<T: Block> {
 
  public let parameters: Parameters
  
  public let options: Options
  
  public weak var delegate: P2PNetworkDelegate?
  
  public let hashingAlgorithm: HashingAlgorithm
  
  var connecting: Bool = false
  
  fileprivate(set) public var peers: [Peer] = []
  
  var connections: [String: Connection] = [:]
  
  let connectingGroup = DispatchGroup()
  
  fileprivate var hasConnected: Bool = false {
    didSet {
      if hasConnected && !oldValue {
        connectingGroup.leave()
      } else if !hasConnected && oldValue {
        connectingGroup.enter()
      }
    }
  }
  
  var isConnected: Bool {
    return peers.count > 0
  }
  
  fileprivate var connectionCountTimer: Timer? = nil
  
  fileprivate var messageHandlers: [MessageHandler] = [PingHandler(), VersionHandler()]
  
  public init(parameters: Parameters, options: Options = Options(), hashingAlgorithm: HashingAlgorithm = NeoScrypt(), delegate: P2PNetworkDelegate? = nil) {
    self.parameters = parameters
    self.options = options
    self.delegate = delegate
    self.hashingAlgorithm = hashingAlgorithm
    self.connectingGroup.enter()
    self.messageHandlers.append(AddrHandler(delegate: self))
//    messageHandlers.append(BlockHandler(hashingAlgorithm: hashingAlgorithm, callback: self.onBlocks))
  }
  
  public func connect() {
    connecting = true
    fillPeers()
    self.connectionCountTimer?.invalidate()
    self.connectionCountTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
      if self.isConnected && self.peers.count < self.options.numberPeers {
        self.getAddresses()
      }
    })
  }
  
  public func waitForConnection(callback: @escaping () -> Void) {
    guard !isConnected else { return callback() }
    connectingGroup.notify(queue: DispatchQueue.main) {
      callback()
    }
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
  
  public func getHeaders(locators: [Data], stop: Data? = nil, callback: @escaping(Result<[BlockHeader]>) -> ()) {
    waitForConnection {
      var called: Bool = false

      let peer = self.peers.random()
        
      peer.getHeaders(locator: locators, stop: stop) { (result, peer) in
        guard !called else { return }
        called = true
        DispatchQueue.main.async {
          switch result {
          case .failure(let error):
            if let e = error as? Peer.Error, e == .timeout {
              self.getHeaders(locators: locators, stop: stop, callback: callback)
            } else {
              callback(.failure(error))
            }
          case .success(let headers):
            callback(.success(headers))
          }
        }
      }
    }
  }
  
  public func getBlockHashes(locators: [Data], callback: @escaping(Result<[Data]>) -> ()) {
    let peer = peers.random()
    
    peer.getBlockHashes(locators: locators) { (result: Result<[Data]>, peer: Peer) in
      DispatchQueue.main.async {
        switch result {
        case .failure(let error):
          if let e = error as? Peer.Error, e == .timeout {
            self.getBlockHashes(locators: locators, callback: callback)
          } else {
            return callback(result)
          }
        case .success(_): callback(result)
        }
      }
    }
  }
  
  public func get(blocks hashes: [Data], callback: @escaping(Result<[T]>) -> ()) {
    let peer = peers.random()

    peer.get(blocks: hashes) { (result: Result<[T]>, peer: Peer) in
      DispatchQueue.main.async {
        switch result {
        case .failure(let error):
          if let e = error as? Peer.Error, e == .timeout {
            self.get(blocks: hashes, callback: callback)
          } else {
            callback(.failure(error))
          }
        case .success(let blocks): callback(.success(blocks))
        }
      }
    }
  }
  
  
  public func broadcast<TX: Transaction>(transaction: TX) {
    peers.forEach { peer in
      peer.broadcast(transaction: transaction)
    }
  }
  
  public func getAddresses() {
    let peer = peers.random()
    peer.getAddresses()
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
    public let magic: Magic
    
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
  
  func onBlocks(_ block: Result<[T]>, _ peer: Peer) {
  
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
    connection.connect { result in
      switch result {
      case .success(_):
        let params = Peer.Params(magic: self.parameters.magic,
                                 hashingAlgorithm: self.hashingAlgorithm)
        let peer = Peer(connection: connection, params: params, delegate: self)
        peer.sendVersion()
        self.peers.append(peer)
        self.hasConnected = true
        self.delegate?.network(self, didConnectToPeer: peer)
      case .failure(_):
        self.connectPeer()
      }
    }
  }
}

extension P2PNetwork: PeerDelegate {
  func peer(_ peer: Peer, didSendMessage message: Message) {
    let handlers = messageHandlers.filter { $0.handles(message: message) }
    handlers.forEach { $0.handle(message: message, from: peer) }
  }
  
  func peerDidDisconnect(_ peer: Peer) {
    self.connections[peer.address] = nil
    self.peers = peers.filter {
      return peer.address != $0.address
    }
    if self.peers.count == 0 {
      hasConnected = false
    }
    
    fillPeers()
  }
}

extension P2PNetwork: AddrHandlerDelegate {
  func handler(_ handler: AddrHandler, didReceiveAddrs addrs: [Addr]) {
    let timeDelta: TimeInterval = 60 * 60 * 12
    let earliest = Date(timeIntervalSinceNow: -timeDelta)

    let fresh = addrs.filter { $0.date > earliest }
    
    let missing = Int(options.numberPeers) - peers.count
    
    guard missing > 0 else { return }
    (0 ..< missing).forEach { _ in
      let addr = fresh.random()
      self.connectStream(address: addr.address)
    }
  }
}
