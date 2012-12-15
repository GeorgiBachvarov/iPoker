//
//  HandStrength.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

typedef enum{
    HandRankingNone = 0,
    HandRankingOnePair = 1,
    HandRankingTwoPair = 2,
    HandRankingThreeOfAKind = 3,
    HandRankingStraight = 4,
    HandRankingFlush = 5,
    HandRankingFullHouse = 6,
    HandRankingFourOfAKind = 7,
    HandRankingStraightFlush = 8,
    HandRankingRoyalFlush = 9
}HandRanking;

@interface HandStrength : NSObject

@property (nonatomic, assign) HandRanking handRanking;
@property (nonatomic, assign) CardRank highCard;

@end
