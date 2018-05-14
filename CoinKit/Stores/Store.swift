//
//  Store.swift
//  CoinKit
//
//  Created by Elliott Minns on 04/05/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

class Store {
  init(dbName: String) {
    
  }
  
  func get(_ key: String) -> String {
    
  }
  
  func put(_ key: String, value: String) -> Bool {
    
  }

  func delete(_ )
  
  -(bool)delete:(nonnull NSString *)key;
  
  -(bool)deleteBatch:(nonnull NSArray *)keys;
  
  -(nonnull NSArray *)iterate:(nonnull NSString *)key;
  
  -(void)close;

}
