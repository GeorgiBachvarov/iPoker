//
//  HistoryManager.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/17/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerDecision.h"
#import "PlayerHoleDecision.h"
#import "PokerBot.h"


@interface HistoryManager : NSObject


+ (HistoryManager *) sharedInstance;

@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) addPlayerDecisionWithRanking: (HandRanking) ranking highCard: (CardRank) highCard andStrategy: (Strategy) strategy forRound: (Round)round;
- (void) addPlayerHoleDecisionWithFirstCard: (CardRank) firstCardRank secondCard: (CardRank) secondCardRank suited:(BOOL) suited andStrategy: (Strategy) strategy;

- (NSArray *) fetchPlayerDecisionsForRound: (Round) round;
- (NSArray *) fetchPlayerHoleDecisions;

@end
