//
//  Card.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    CardRankTwo = 0,
    CardRankThree = 1,
    CardRankFour = 2,
    CardRankFive = 3,
    CardRankSix = 4,
    CardRankSeven = 5,
    CardRankEight = 6,
    CardRankNine = 7,
    CardRankTen = 8,
    CardRankJack = 9,
    CardRankQueen = 10,
    CardRankKing = 11,
    CardRankAce = 12
}CardRank;

typedef enum{
    CardSuitClubs = 0,
    CardSuitDiamonds = 1,
    CardSuitHearts = 2,
    CardSuitSpades = 3
}CardSuit;

@interface Card : NSObject

@property (nonatomic, assign) CardRank rank;
@property (nonatomic, assign) CardSuit suit;

+ (UIImage *) cardBack;
- (UIImage *) visualRepresentation;
- (id)initWithRank: (CardRank) rank andSuit: (CardSuit) suit;
+ cardWithRank: (CardRank) rank andSuit: (CardSuit) suit;

@end
