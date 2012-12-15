//
//  GameState.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "HandStrength.h"


@interface GameState : NSObject

//cards
@property (nonatomic, strong) NSMutableArray *deck;
@property (nonatomic, strong) NSMutableArray *playerHand;
@property (nonatomic, strong) NSMutableArray *botHand;
@property (nonatomic, strong) NSMutableArray *communityCards;
@property (nonatomic, assign) NSUInteger round;

@end
