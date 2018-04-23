//
//  Secp256k1.swift
//  CoinKit
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import Secp256k1
import BigInt

enum Secp256k1Error: Error {
  case invalidKey
  case input(message: String)
  case invalidTweak
}

class Secp256k1 {
  
  let n = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!

  let context: OpaquePointer
  
  init() {
    self.context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
  }
  
  deinit {
    secp256k1_context_destroy(self.context)
  }
  
  func check(key: Data) -> Bool {
    return key.withUnsafeBytes {
      return secp256k1_ec_seckey_verify(self.context, $0) == 1
    }
  }
  
  func publicKey(from key: Data, compressed: Bool = false) throws -> Data {
    var pub = secp256k1_pubkey()
    
    let result = key.withUnsafeBytes {
      secp256k1_ec_pubkey_create(self.context, &pub, $0)
    }
    
    guard result == 1 else { throw Secp256k1Error.invalidKey }
    
    let length = compressed ? 33 : 65
    var publicKey = Data(count: length)
    let flags = compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED
    publicKey.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt8>) -> Void in
      var len = length
      secp256k1_ec_pubkey_serialize(self.context, buffer, &len, &pub, UInt32(flags))
      return Void()
    }
    
    return publicKey
  }
  
  func add(publicKey: Data, with tweak: Data) throws -> Data {
    guard tweak.count == 32 else { throw Secp256k1Error.input(message: "Tweak is not 32 bytes") }
    var pub = secp256k1_pubkey()
    let parseResult = publicKey.withUnsafeBytes {
      secp256k1_ec_pubkey_parse(context, &pub, $0, publicKey.count)
    }
    
    guard parseResult == 1 else { throw Secp256k1Error.invalidKey }
    
    let tweakResult = tweak.withUnsafeBytes {
      secp256k1_ec_pubkey_tweak_add(context, &pub, $0)
    }
    
    guard tweakResult == 1 else { throw Secp256k1Error.invalidTweak }
    
    let length = 33
    var publicKey = Data(count: length)
    let flags = SECP256K1_EC_COMPRESSED
    publicKey.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt8>) -> Void in
      var len = length
      secp256k1_ec_pubkey_serialize(self.context, buffer, &len, &pub, UInt32(flags))
      return Void()
    }
    
    return publicKey
  }
  
  func sign(hash: Data, privateKey: Data) -> Data {
    var signature = secp256k1_ecdsa_signature()
    
    _ = hash.withUnsafeBytes { msg in
      return privateKey.withUnsafeBytes { seckey in
        secp256k1_ecdsa_sign(context, &signature, msg, seckey, nil, nil)
      }
    }
    
    let length = 33
    var sigData = Data(count: length)
    sigData.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt8>) -> Void in
      var len = length
      secp256k1_ecdsa_signature_serialize_der(context, buffer, &len, &signature)
      return Void()
    }
    
    return sigData
  }
}
