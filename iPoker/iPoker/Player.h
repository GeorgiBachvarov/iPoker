//
//  Player.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface Player : NSObject

@property (nonatomic, strong) GameState *gameState;
@property (nonatomic, assign) NSUInteger moneyLeft;
@property (nonatomic, assign) BOOL isDealer;

-initWithGameState: (GameState *) state;
- (HandStrength *) evaluateHand;
-(NSArray *) availableCards;
-(PlayerAction *) nextAction;

@end
