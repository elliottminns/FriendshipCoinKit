//
//  HDNodeSpec.swift
//  CoinKitTests
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Quick
import Nimble
@testable import CoinKit

class HDNodeSpec: QuickSpec {
  override func spec() {
    describe("The HD node") {
      let seed = "000102030405060708090a0b0c0d0e0f"
      let node = try? HDNode(seedHex: seed, network: .bitcoin)
      
      it("should exist") {
        expect(node).toNot(beNil())
      }
      
      it("should have the correct public key") {
        expect(node?.keyPair.publicKey.hexEncodedString()) == "0339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
      }
      
      it("should have the correct address") {
        expect(node?.address) == "15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma"
      }
      
      it("should have the correct identifier") {
        expect(node?.identifier.hexEncodedString()) == "3442193e1bb70916e914552172cd4e2dbc9df811"
      }
      
      it("should have the correct fingerprint") {
        expect(node?.fingerprint.hexEncodedString()) == "3442193e"
      }
      
      describe("deriving a hardened child") {
        let child = try? node!.deriveHardened(0)
        
        it("should exist") {
          expect(child).toNot(beNil())
        }
        
        it("should have the correct index") {
          expect(child?.index) == 2147483648
        }
        
        it("should have the correct address") {
          expect(child?.address) == "19Q2WoS5hSS6T8GjhK8KZLMgmWaq4neXrh"
        }
        
        it("should have the correct public key") {
          expect(child?.keyPair.publicKey.hexEncodedString()) == "035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56"
        }
        
        it("should have the correct chain code") {
          expect(child?.chainCode.hexEncodedString()) == "47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141"
        }
      }
    }
  }
}
