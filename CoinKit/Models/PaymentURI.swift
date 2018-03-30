//
//  PaymentURI.swift
//  CoinKit
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

public struct PaymentURI {
  
  let _amount: String?
  
  public let address: String
  
  let network: Network
  
  public var amount: String? {
    if let amount = _amount { return amount }
    
    if let amount = keyValues["amount"], let _ = Double(amount) {
      return amount
    } else {
      return nil
    }
  }
  
  let keyValues: [String: String]
  
  let _uri: String?
  
  public var uri: String {
    if let uri = _uri { return uri }
    return buildUri()
  }
  
  public init(address: String, amount: String? = nil, network: Network) {
    self.address = address
    _amount = amount
    keyValues = [:]
    _uri = nil
    self.network = network
  }
  
  public init?(uri: String, network: Network) {
    _uri = uri
    _amount = nil
    self.network = network
    
    let comps = uri.components(separatedBy: "?")
    
    guard let addressComp = comps.first,
      let address = addressComp.components(separatedBy: ":").last else {
        return nil
    }
    
    self.address = address
    
    if comps.last != comps.first {
      let params = comps.last?.components(separatedBy: "&") ?? []
      let keyValues = params.reduce([:], { (data, string) -> [String: String] in
        var data = data
        let keyValue = string.components(separatedBy: "=")
        guard let first = keyValue.first, let last = keyValue.last,
          first != last else { return data }
        data[first] = last
        return data
      })
      
      self.keyValues = keyValues
    } else {
      self.keyValues = [:]
    }
  }

  func buildUri() -> String {
    let uri = "\(network):\(address)"
    
    var params = "?"
    if let amount = _amount {
      params.append("amount=\(amount)")
    }
    
    let full = params.count > 1 ? uri + params : uri
    return full
  }
}
