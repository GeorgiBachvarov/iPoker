//
//  GameOptions.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/16/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameOptions : NSObject

#define DEFAULT_MONEY_LIMIT 1000
#define DEFAULT_MINIMUM_BET 100
#define DEFAULT_PLAYER_MONEY 5000
#define DEFAULT_PLAYER_NAME @"NERF IRELIA"

@property (nonatomic, assign) NSUInteger moneyLimit;
@property (nonatomic, assign) NSUInteger startingMoney;
@property (nonatomic, assign) NSUInteger minimumBet;
@property (nonatomic, retain) NSString *playerName;

@end
