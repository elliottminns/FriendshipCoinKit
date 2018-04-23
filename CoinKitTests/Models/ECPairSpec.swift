//
//  ECPairSpec.swift
//  CoinKitTests
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Quick
import Nimble
@testable import CoinKit

class ECPairSpec: QuickSpec {
  override func spec() {
    describe("creating a pair with private key of 1 for bitcoin") {
      let key = "0000000000000000000000000000000000000000000000000000000000000001".hexadecimal()!
      let pair = try? ECPair(privateKey: key, network: NetworkType.bitcoin, compressed: false)
      
      it("should be valid") {
        expect(pair).toNot(beNil())
      }
      
      it("should have the correct public key") {
        let pub = pair?.publicKey.hexEncodedString()
        expect(pub) == "0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8"
      }
      
      it("should have the correct address") {
        let address = pair?.address
        expect(address) == "1EHNa6Q4Jz2uvNExL497mE43ikXhwF6kZm"
      }
    }
    
    describe("Another key pair") {
      let key = "e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35".hexadecimal()!
      let pair = try? ECPair(privateKey: key, network: NetworkType.bitcoin)
      
      it("should be valid") {
        expect(pair).toNot(beNil())
      }
      
      it("should have the correct public key") {
        let pub = pair?.publicKey.hexEncodedString()
        expect(pub) == "0339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
      }
      
      it("should have the correct address") {
        let address = pair?.address
        expect(address) == "15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma"
      }
    }
  }
}
