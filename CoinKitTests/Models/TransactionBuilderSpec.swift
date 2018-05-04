//
//  TransactionBuilderSpec.swift
//  CoinKitTests
//
//  Created by Elliott Minns on 02/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Quick
import Nimble
@testable import CoinKit

class TransactionBuilderSpec: QuickSpec {
  
  struct InputFixture {
    let txID: String
    let vout: Int
    let signs: [[String: String]]
    let prevTxScript: String?
  }
  
  struct OutputFixture {
    let script: String
    let value: UInt64
  }

  struct Fixture {
    let description: String
    let txHex: String
    let inputs: [InputFixture]
    let outputs: [OutputFixture]
  }
  
  override func spec() {
    describe("The transaction builder") {
      
      var builder: BitcoinTransaction.Builder!
      
      beforeEach {
        builder = BitcoinTransaction.Builder(network: NetworkType.bitcoin)
      }
      
      it("should correctly set the index of added transactions") {
        let hashA = "abcde"
        let hashB = "edcba"
        let indexA = try! builder.add(transaction: hashA)
        let indexB = try! builder.add(transaction: hashB)
        
        expect(indexA) == 1
        expect(indexB) == 2
      }
      
      it("should throw an error when using an input more that once") {
        
      }
    }
    
    describe("building a transaction") {
      
      let fixtures: [Fixture] = [
        Fixture(
          description: "Transaction w/ P2PKH -> P2PKH",
          txHex: "0100000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000006b483045022100a3b254e1c10b5d039f36c05f323995d6e5a367d98dd78a13d5bbc3991b35720e022022fccea3897d594de0689601fbd486588d5bfa6915be2386db0397ee9a6e80b601210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798ffffffff0110270000000000001976a914aa4d7985c57e011a8b3dd8e0e5a73aaef41629c588ac00000000",
          inputs: [
            InputFixture(
              txID: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
              vout: 0,
              signs: [
                [
                "keyPair": "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn"
                ]
              ],
              prevTxScript: nil)
          ],
          outputs: [
            OutputFixture(
              script: "OP_DUP OP_HASH160 aa4d7985c57e011a8b3dd8e0e5a73aaef41629c5 OP_EQUALVERIFY OP_CHECKSIG",
              value: 10000
            )
          ])
      ]
      
      describe("from transaction") {
        fixtures.forEach { fixture in
          describe("with \(fixture.description)") {
            let transaction = try! BitcoinTransaction(hex: fixture.txHex)
            let builder = BitcoinTransaction.Builder(transaction: transaction, network: NetworkType.bitcoin)
            let txb = try? builder.build()

            it("should build a transaction") {
              expect(txb).toNot(beNil())
            }
          }
        }
      }
    }
    
    describe("signing a transaction") {
      struct TestSignable: Signable {
        let publicKey = Data(repeating: 0x03, count: 33)
        
        func sign(_ hash: Data) throws -> ECSignature {
          return ECSignature(data: Data(count: 64))
        }
        
        var network: Network = NetworkType.bitcoin
      }
      
      let builder = BitcoinTransaction.Builder(network: NetworkType.bitcoin)
      try? builder.add(input: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", vout: 1)
      try? builder.add(output: "1111111111111111111114oLvT2", amount: UInt64(1e5))
      try? builder.sign(vin: 0, signable: TestSignable())

      it("should support signable") {
        let hex = try! builder.build().toData(allowWitness: false)
        expect(hex) == "0100000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff010000002c0930060201000201000121030303030303030303030303030303030303030303030303030303030303030303ffffffff01a0860100000000001976a914000000000000000000000000000000000000000088ac00000000".hexadecimal()
      }
    }
  }
}
