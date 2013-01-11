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
#import "GameStateDelegate.h"

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
@property (nonatomic, assign) BOOL playerIsAllIn;
@property (nonatomic, assign) BOOL botIsAllIn;

@property (nonatomic, assign) id <GameStateDelegate> player;
@property (nonatomic, assign) id <GameStateDelegate> bot;

- (id) initWithGameOptions: (GameOptions *) options;
- (void) getNewDeck;
- (void) shuffleDeck;
- (void) finalizeGame;
- (void) prepareForNextGame;

@end
