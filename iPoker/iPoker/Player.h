//
//  Player.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "GameStateDelegate.h"

@interface Player : NSObject <GameStateDelegate>

@property (nonatomic, strong) GameState *gameState;
@property (nonatomic, assign) NSUInteger moneyLeft;

-initWithGameState: (GameState *) state;
-(NSArray *) availableCards;

@end
