//
//  LevelUp.h
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject

-(nonnull instancetype)initWithDBName:(nonnull NSString *) dbName;

-(nonnull NSString *)get:(nonnull NSString *)key;

-(bool)put:(nonnull NSString *)key value:(nonnull NSString *)value;

-(bool)delete:(nonnull NSString *)key;

-(bool)deleteBatch:(nonnull NSArray *)keys;

-(nonnull NSArray *)iterate:(nonnull NSString *)key;

-(void)close;

@end
