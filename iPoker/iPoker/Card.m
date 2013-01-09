//
//  Card.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "Card.h"

@implementation Card


-(UIImage *)visualRepresentation{
    //view for card
    return [UIImage imageNamed:[self description]];
}

- (id)initWithRank:(CardRank)rank andSuit:(CardSuit)suit{
    self = [self init];
    if (self){
        self.rank = rank;
        self.suit = suit;
    }
    return self;
}

+ (id)cardWithRank:(CardRank)rank andSuit:(CardSuit)suit{
    return [[Card alloc] initWithRank:rank andSuit:suit];
}

- (NSString *)description{
    NSString *rankString;
    
    switch (self.rank) {
        case CardRankTwo:
            rankString = @"2";
            break;
        case CardRankThree:
            rankString = @"3";
            break;
        case CardRankFour:
            rankString = @"4";
            break;
        case CardRankFive:
            rankString = @"5";
            break;
        case CardRankSix:
            rankString = @"6";
            break;
        case CardRankSeven:
            rankString = @"7";
            break;
        case CardRankEight:
            rankString = @"8";
            break;
        case CardRankNine:
            rankString = @"9";
            break;
        case CardRankTen:
            rankString = @"10";
            break;
        case CardRankJack:
            rankString = @"Jack";
            break;
        case CardRankQueen:
            rankString = @"Queen";
            break;
        case CardRankKing:
            rankString = @"King";
            break;
        case CardRankAce:
            rankString = @"Ace";
            break;
        default:
            rankString = @"Invalid Rank";
            break;
    }
    
    NSString *suitString;
    
    switch (self.suit) {
        case CardSuitClubs:
            suitString = @"Clubs";
            break;
        case CardSuitDiamonds:
            suitString = @"Diamonds";
            break;
        case CardSuitHearts:
            suitString = @"Hearts";
            break;
        case CardSuitSpades:
            suitString = @"Spades";
            break;
        default:
            suitString = @"Invalid Suit";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ Of %@", rankString, suitString];
}

+ (UIImage *)cardBack{
    return [UIImage imageNamed:@"playingCardBack"];
}

@end
