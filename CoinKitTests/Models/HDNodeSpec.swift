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
      
      describe("deriving a normal child") {
        let child = try? node!.derive(10)
        
        it("should exist") {
          expect(child).toNot(beNil())
        }
        
        it("should have the correct index") {
          expect(child?.index) == 10
        }
        
        it("should have the correct address") {
          expect(child?.address) == "1Gf2zE6vqRxfb3C8JgKkcUUD6qqxTqAh2N"
        }
        
        it("should have the correct public key") {
          expect(child?.keyPair.publicKey.hexEncodedString()) == "036b7194665a4a2c149025c1c1753f948dd826fab3578fa3d2a6f0848d445bf8e9"
        }
        
        it("should have the correct chain code") {
          expect(child?.chainCode.hexEncodedString()) == "4db55d5fce1b3eac184ac9dbc1e3a0fa888fdd282bbcd3fadbe37c7fcd9577e6"
        }
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
      /*
      describe("deriving a path") {
        let path = "m/0'/1/2'/2/1000000000"
        let child = try? node!.derive(path: path)
        
        it("should exist") {
          expect(child).toNot(beNil())
        }
        
        it("should have the correct address") {
          expect(child?.address) == "1LZiqrop2HGR4qrH1ULZPyBpU6AUP49Uam"
        }
        
        it("should have the correct identifier") {
          expect(child?.identifier.hexEncodedString()) == "d69aa102255fed74378278c7812701ea641fdf32"
        }
        
        it("should have the correct fingerprint") {
          expect(child?.fingerprint.hexEncodedString()) == "d69aa102"
        }
      }*/
    }
  }
}
