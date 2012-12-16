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
#import "PlayerAction.h"
#import "GameOptions.h"

#define DEFAULT_MONEY_LIMIT 1000
#define DEFAULT_MINIMUM_BET 100
#define DEFAULT_PLAYER_MONEY 5000

typedef enum{
    RoundBettingRound = 0,
    RoundTheFlop = 1,
    RoundTheTurn = 2,
    RoundTheRiver = 3
} Round;


@interface GameState : NSObject

//cards
@property (nonatomic, strong) NSMutableArray *deck;
@property (nonatomic, strong) NSMutableArray *playerHand;
@property (nonatomic, strong) NSMutableArray *botHand;
@property (nonatomic, strong) NSMutableArray *communityCards;
@property (nonatomic, assign) Round round;
@property (nonatomic, retain) GameOptions *options;
@property (nonatomic, assign) NSUInteger currentPot;
@property (nonatomic, assign) NSUInteger currentRaise;

-(id)initWithGameOptions: (GameOptions *) options;

@end
