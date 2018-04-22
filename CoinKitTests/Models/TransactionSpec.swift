//
//  Transaction.swift
//  CoinKitTests
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Quick
import Nimble
@testable import CoinKit

class TransactionSpec: QuickSpec {
  
  struct RawInput {
    let hash: String
    
    let index: Int
    
    let script: String
    
    let sequence: UInt?
  }
  
  struct RawOutput {
    let script: String
    
    let value: UInt64
  }
  
  struct TransactionData {
    let version: Int
    
    let inputs: [RawInput]
    
    let outputs: [RawOutput]
    
    let locktime: Int
  }
  
  struct Fixture {
    
    let description: String
    
    let id: String
    
    let hash: String
    
    let hex: String

    let raw: TransactionData
    
    let coinbase: Bool
    
    let virtualSize: Int
    
    let weight: UInt
  }
  
  let fixtures: [Fixture] = [
    Fixture(
      description: "Standard transaction (1:1)",
      id: "a0ff943d3f644d8832b1fa74be4d0ad2577615dc28a7ef74ff8c271b603a082a",
      hash: "2a083a601b278cff74efa728dc157657d20a4dbe74fab132884d643f3d94ffa0",
      hex: "0100000001f1fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe000000006b4830450221008732a460737d956fd94d49a31890b2908f7ed7025a9c1d0f25e43290f1841716022004fa7d608a291d44ebbbebbadaac18f943031e7de39ef3bf9920998c43e60c0401210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798ffffffff01a0860100000000001976a914c42e7ef92fdb603af844d064faad95db9bcdfd3d88ac00000000",
      raw: TransactionData(
        version: 1,
        inputs: [
          RawInput(
            hash: "f1fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe",
            index: 0,
            script: "30450221008732a460737d956fd94d49a31890b2908f7ed7025a9c1d0f25e43290f1841716022004fa7d608a291d44ebbbebbadaac18f943031e7de39ef3bf9920998c43e60c0401",
            sequence: nil
          )
        ],
        outputs: [
          RawOutput(
            script: "OP_DUP OP_HASH160 c42e7ef92fdb603af844d064faad95db9bcdfd3d OP_EQUALVERIFY OP_CHECKSIG",
            value: 100000)
        ],
        locktime: 0),
      coinbase: false,
      virtualSize: 192,
      weight: 768),
    Fixture(
      description: "Standard transaction (2:2)",
      id: "fcdd6d89c43e76dcff94285d9b6e31d5c60cb5e397a76ebc4920befad30907bc",
      hash: "bc0709d3fabe2049bc6ea797e3b50cc6d5316e9b5d2894ffdc763ec4896dddfc",
      hex: "0100000002f1fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe000000006b483045022100e661badd8d2cf1af27eb3b82e61b5d3f5d5512084591796ae31487f5b82df948022006df3c2a2cac79f68e4b179f4bbb8185a0bb3c4a2486d4405c59b2ba07a74c2101210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798fffffffff2fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe0100000083483045022100be54a46a44fb7e6bf4ebf348061d0dace7ddcbb92d4147ce181cf4789c7061f0022068ccab2a89a47fc29bb5074bca99ae846ab446eecf3c3aaeb238a13838783c78012102c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee517a9147ccb85f0ab2d599bc17246c98babd5a20b1cdc7687000000800250c30000000000001976a914c42e7ef92fdb603af844d064faad95db9bcdfd3d88acf04902000000000017a9147ccb85f0ab2d599bc17246c98babd5a20b1cdc768700000000",
      raw: TransactionData(
        version: 1,
        inputs: [
          RawInput(
            hash: "f1fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe",
            index: 0,
            script: "3045022100e661badd8d2cf1af27eb3b82e61b5d3f5d5512084591796ae31487f5b82df948022006df3c2a2cac79f68e4b179f4bbb8185a0bb3c4a2486d4405c59b2ba07a74c2101",
            sequence: 4294967295
          ),
          RawInput(
            hash: "f2fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe",
            index: 1,
            script: "3045022100be54a46a44fb7e6bf4ebf348061d0dace7ddcbb92d4147ce181cf4789c7061f0022068ccab2a89a47fc29bb5074bca99ae846ab446eecf3c3aaeb238a13838783c7801",
            sequence: 2147483648
          )
        ],
        outputs: [
          RawOutput(
            script: "OP_DUP OP_HASH160 c42e7ef92fdb603af844d064faad95db9bcdfd3d OP_EQUALVERIFY OP_CHECKSIG",
            value: 50000
          ),
          RawOutput(
            script: "OP_HASH160 7ccb85f0ab2d599bc17246c98babd5a20b1cdc76 OP_EQUAL",
            value: 150000
          )
        ],
        locktime: 0
      ),
      coinbase: false,
      virtualSize: 396,
      weight: 1584
    ),
    Fixture(
      description: "Standard transaction (14:2)",
      id: "39d57bc27f72e904d81f6b5ef7b4e6e17fa33a06b11e5114a43435830d7b5563",
      hash: "63557b0d833534a414511eb1063aa37fe1e6b4f75e6b1fd804e9727fc27bd539",
      hex: "010000000ee7b73e229790c1e79a02f0c871813b3cf26a4156c5b8d942e88b38fe8d3f43a0000000008c493046022100fd3d8fef44fb0962ba3f07bee1d4cafb84e60e38e6c7d9274504b3638a8d2f520221009fce009044e615b6883d4bf62e04c48f9fe236e19d644b082b2f0ae5c98e045c014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff7bfc005f3880a606027c7cd7dd02a0f6a6572eeb84a91aa158311be13695a7ea010000008b483045022100e2e61c40f26e2510b76dc72ea2f568ec514fce185c719e18bca9caaef2b20e9e02207f1100fc79eb0584e970c7f18fb226f178951d481767b4092d50d13c50ccba8b014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff0e0f8e6bf951fbb84d7d8ef833a1cbf5bb046ea7251973ac6e7661c755386ee3010000008a473044022048f1611e403710f248f7caf479965a6a5f63cdfbd9a714fef4ec1b68331ade1d022074919e79376c363d4575b2fc21513d5949471703efebd4c5ca2885e810eb1fa4014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffe6f17f35bf9f0aa7a4242ab3e29edbdb74c5274bf263e53043dddb8045cb585b000000008b483045022100886c07cad489dfcf4b364af561835d5cf985f07adf8bd1d5bd6ddea82b0ce6b2022045bdcbcc2b5fc55191bb997039cf59ff70e8515c56b62f293a9add770ba26738014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffe6f17f35bf9f0aa7a4242ab3e29edbdb74c5274bf263e53043dddb8045cb585b010000008a4730440220535d49b819fdf294d27d82aff2865ed4e18580f0ca9796d793f611cb43a44f47022019584d5e300c415f642e37ba2a814a1e1106b4a9b91dc2a30fb57ceafe041181014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffd3051677216ea53baa2e6d7f6a75434ac338438c59f314801c8496d1e6d1bf6d010000008b483045022100bf612b0fa46f49e70ab318ca3458d1ed5f59727aa782f7fac5503f54d9b43a590220358d7ed0e3cee63a5a7e972d9fad41f825d95de2fd0c5560382468610848d489014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff1e751ccc4e7d973201e9174ec78ece050ef2fadd6a108f40f76a9fa314979c31010000008b483045022006e263d5f73e05c48a603e3bd236e8314e5420721d5e9020114b93e8c9220e1102210099d3dead22f4a792123347a238c87e67b55b28a94a0bb7793144cc7ad94a0168014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff25c4cf2c61743b3f4252d921d937cca942cf32e4f3fa4a544d0b26f014337084010000008a47304402207d6e87588be47bf2d97eaf427bdd992e9d6b306255711328aee38533366a88b50220623099595ae442cb77eaddb3f91753a4fc9df56fde69cfec584c7f97e05533c8014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffecd93c87eb43c48481e6694904305349bdea94b01104579fa9f02bff66c89663010000008a473044022020f59498aee0cf82cb113768ef3cb721000346d381ff439adb4d405f791252510220448de723aa59412266fabbc689ec25dc94b1688c27a614982047513a80173514014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffa1fdc0a79ff98d5b6154176e321c22f4f8450dbd950bd013ad31135f5604411e010000008b48304502210088167867f87327f9c0db0444267ff0b6a026eedd629d8f16fe44a34c18e706bf0220675c8baebf89930e2d6e4463adefc50922653af99375242e38f5ee677418738a014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffb89e8249c3573b58bf1ec7433185452dd57ab8e1daab01c3cc6ddc8b66ad3de8000000008b4830450220073d50ac5ec8388d5b3906921f9368c31ad078c8e1fb72f26d36b533f35ee327022100c398b23e6692e11dca8a1b64aae2ff70c6a781ed5ee99181b56a2f583a967cd4014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff45ee07e182084454dacfad1e61b04ffdf9c7b01003060a6c841a01f4fff8a5a0010000008b483045022100991d1bf60c41358f08b20e53718a24e05ac0608915df4f6305a5b47cb61e5da7022003f14fc1cc5b737e2c3279a4f9be1852b49dbb3d9d6cc4c8af6a666f600dced8014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff4cba12549f1d70f8e60aea8b546c8357f7c099e7c7d9d8691d6ee16e7dfa3170010000008c493046022100f14e2b0ef8a8e206db350413d204bc0a5cd779e556b1191c2d30b5ec023cde6f022100b90b2d2bf256c98a88f7c3a653b93cec7d25bb6a517db9087d11dbd189e8851c014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffffa4b3aed39eb2a1dc6eae4609d9909724e211c153927c230d02bd33add3026959010000008b483045022100a8cebb4f1c58f5ba1af91cb8bd4a2ed4e684e9605f5a9dc8b432ed00922d289d0220251145d2d56f06d936fd0c51fa884b4a6a5fafd0c3318f72fb05a5c9aa372195014104aa592c859fd00ed2a02609aad3a1bf72e0b42de67713e632c70a33cc488c15598a0fb419370a54d1c275b44380e8777fc01b6dc3cd43a416c6bab0e30dc1e19fffffffff0240d52303000000001976a914167c3e1f10cc3b691c73afbdb211e156e3e3f25c88ac15462e00000000001976a914290f7d617b75993e770e5606335fa0999a28d71388ac00000000",
      raw: TransactionData(
        version: 1,
        inputs: [
          RawInput(
            hash: "e7b73e229790c1e79a02f0c871813b3cf26a4156c5b8d942e88b38fe8d3f43a0",
            index: 0,
            script: "3046022100fd3d8fef44fb0962ba3f07bee1d4cafb84e60e38e6c7d9274504b3638a8d2f520221009fce009044e615b6883d4bf62e04c48f9fe236e19d644b082b2f0ae5c98e045c01",
            sequence: nil
          ),
          RawInput(
            hash: "7bfc005f3880a606027c7cd7dd02a0f6a6572eeb84a91aa158311be13695a7ea",
            index: 1,
            script: "3045022100e2e61c40f26e2510b76dc72ea2f568ec514fce185c719e18bca9caaef2b20e9e02207f1100fc79eb0584e970c7f18fb226f178951d481767b4092d50d13c50ccba8b01",
            sequence: nil
          ),
          RawInput(
            hash: "0e0f8e6bf951fbb84d7d8ef833a1cbf5bb046ea7251973ac6e7661c755386ee3",
            index: 1,
            script: "3044022048f1611e403710f248f7caf479965a6a5f63cdfbd9a714fef4ec1b68331ade1d022074919e79376c363d4575b2fc21513d5949471703efebd4c5ca2885e810eb1fa401",
            sequence: nil
          ),
          RawInput(
            hash: "e6f17f35bf9f0aa7a4242ab3e29edbdb74c5274bf263e53043dddb8045cb585b",
            index: 0,
            script: "3045022100886c07cad489dfcf4b364af561835d5cf985f07adf8bd1d5bd6ddea82b0ce6b2022045bdcbcc2b5fc55191bb997039cf59ff70e8515c56b62f293a9add770ba2673801",
            sequence: nil
          ),
          RawInput(
            hash: "e6f17f35bf9f0aa7a4242ab3e29edbdb74c5274bf263e53043dddb8045cb585b",
            index: 1,
            script: "30440220535d49b819fdf294d27d82aff2865ed4e18580f0ca9796d793f611cb43a44f47022019584d5e300c415f642e37ba2a814a1e1106b4a9b91dc2a30fb57ceafe04118101",
            sequence: nil
          ),
          RawInput(
            hash: "d3051677216ea53baa2e6d7f6a75434ac338438c59f314801c8496d1e6d1bf6d",
            index: 1,
            script: "3045022100bf612b0fa46f49e70ab318ca3458d1ed5f59727aa782f7fac5503f54d9b43a590220358d7ed0e3cee63a5a7e972d9fad41f825d95de2fd0c5560382468610848d48901",
            sequence: nil
          ),
          RawInput(
            hash: "1e751ccc4e7d973201e9174ec78ece050ef2fadd6a108f40f76a9fa314979c31",
            index: 1,
            script: "3045022006e263d5f73e05c48a603e3bd236e8314e5420721d5e9020114b93e8c9220e1102210099d3dead22f4a792123347a238c87e67b55b28a94a0bb7793144cc7ad94a016801",
            sequence: nil
          ),
          RawInput(
            hash: "25c4cf2c61743b3f4252d921d937cca942cf32e4f3fa4a544d0b26f014337084",
            index: 1,
            script: "304402207d6e87588be47bf2d97eaf427bdd992e9d6b306255711328aee38533366a88b50220623099595ae442cb77eaddb3f91753a4fc9df56fde69cfec584c7f97e05533c801",
            sequence: nil
          ),
          RawInput(
            hash: "ecd93c87eb43c48481e6694904305349bdea94b01104579fa9f02bff66c89663",
            index: 1,
            script: "3044022020f59498aee0cf82cb113768ef3cb721000346d381ff439adb4d405f791252510220448de723aa59412266fabbc689ec25dc94b1688c27a614982047513a8017351401",
            sequence: nil
          ),
          RawInput(
            hash: "a1fdc0a79ff98d5b6154176e321c22f4f8450dbd950bd013ad31135f5604411e",
            index: 1,
            script: "304502210088167867f87327f9c0db0444267ff0b6a026eedd629d8f16fe44a34c18e706bf0220675c8baebf89930e2d6e4463adefc50922653af99375242e38f5ee677418738a01",
            sequence: nil
          ),
          RawInput(
            hash: "b89e8249c3573b58bf1ec7433185452dd57ab8e1daab01c3cc6ddc8b66ad3de8",
            index: 0,
            script: "30450220073d50ac5ec8388d5b3906921f9368c31ad078c8e1fb72f26d36b533f35ee327022100c398b23e6692e11dca8a1b64aae2ff70c6a781ed5ee99181b56a2f583a967cd401",
            sequence: nil
          ),
          RawInput(
            hash: "45ee07e182084454dacfad1e61b04ffdf9c7b01003060a6c841a01f4fff8a5a0",
            index: 1,
            script: "3045022100991d1bf60c41358f08b20e53718a24e05ac0608915df4f6305a5b47cb61e5da7022003f14fc1cc5b737e2c3279a4f9be1852b49dbb3d9d6cc4c8af6a666f600dced801",
            sequence: nil
          ),
          RawInput(
            hash: "4cba12549f1d70f8e60aea8b546c8357f7c099e7c7d9d8691d6ee16e7dfa3170",
            index: 1,
            script: "3046022100f14e2b0ef8a8e206db350413d204bc0a5cd779e556b1191c2d30b5ec023cde6f022100b90b2d2bf256c98a88f7c3a653b93cec7d25bb6a517db9087d11dbd189e8851c01",
            sequence: nil
          ),
          RawInput(
            hash: "a4b3aed39eb2a1dc6eae4609d9909724e211c153927c230d02bd33add3026959",
            index: 1,
            script: "3045022100a8cebb4f1c58f5ba1af91cb8bd4a2ed4e684e9605f5a9dc8b432ed00922d289d0220251145d2d56f06d936fd0c51fa884b4a6a5fafd0c3318f72fb05a5c9aa37219501",
            sequence: nil
          ),
        ],
        outputs: [
          RawOutput(
            script: "OP_DUP OP_HASH160 167c3e1f10cc3b691c73afbdb211e156e3e3f25c OP_EQUALVERIFY OP_CHECKSIG",
            value: 52680000
          ),
          RawOutput(
            script: "OP_DUP OP_HASH160 290f7d617b75993e770e5606335fa0999a28d713 OP_EQUALVERIFY OP_CHECKSIG",
            value: 3032597
          )
        ],
        locktime: 0
      ),
      coinbase: false,
      virtualSize: 2596,
      weight: 10384
    )
  ]
  
  override func spec() {
    
    fixtures.forEach { fixture in
      describe(fixture.description) {
        context("creating from transaction hex") {
          
          let transaction = try! Transaction(hex: fixture.hex)
          
          it("should calculate the correct weight") {
            expect(transaction.weight) == fixture.weight
          }
          
          it("should have the correct id") {
            expect(transaction.id) == fixture.id
          }
          
          describe("the raw transaction data") {
            
            it("should have the correct number of inputs") {
              expect(transaction.inputs.count) == fixture.raw.inputs.count
            }
            
            it("should have the correct number of outputs") {
              expect(transaction.outputs.count) == fixture.raw.outputs.count
            }
          }
        }
      }
    }
  }
}
