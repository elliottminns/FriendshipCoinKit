//
//  SHA256.swift
//  CoinKit
//
//  Created by Elliott Minns on 25/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import Crypto

struct Sha256: HashingAlgorithm {
  func hash(data: Data) -> Data {
    return data.sha256
  }
}
