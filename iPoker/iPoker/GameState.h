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
    RoundPostingBlinds = 0,
    RoundBettingRound = 1,
    RoundTheFlop = 2,
    RoundTheTurn = 3,
    RoundTheRiver = 4
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
@property (nonatomic, assign) BOOL playerIsDealer;

-(id)initWithGameOptions: (GameOptions *) options;
- (void) finalizeGame;
- (void) prepareForNextGame;

@end
