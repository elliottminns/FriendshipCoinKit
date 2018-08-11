//
//  Data+Crypto.swift
//  CoinKit
//
//  Created by Elliott Minns on 21/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
  var hash160: Data {
    return self.sha256.ripemd160
  }
}
