//
//  LevelUp.h
//  CoinKit
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface Store : NSObject

-(instancetype)initWithDBName:(nonnull NSString *) dbName;

-(NSString *)get:(NSString *)key;

-(bool)put:(NSString *)key value:(NSString *)value;

-(bool)delete:(NSString *)key;

-(bool)deleteBatch:(NSArray *)keys;

-(NSArray *)iterate:(NSString *)key;

-(void)close;

@end

NS_ASSUME_NONNULL_END
