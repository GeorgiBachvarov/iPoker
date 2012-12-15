//
//  GameState.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "GameState.h"

@implementation GameState

- (id)init
{
    self = [super init];
    if (self) {
        
        self.playerHand = [[NSMutableArray alloc] init];
        self.botHand = [[NSMutableArray alloc] init];
        self.communityCards = [[NSMutableArray alloc] init];
        
        [self getNewDeck];
        [self shuffleDeck];
    }
    return self;
}

- (void) getNewDeck{
    self.deck = [[NSMutableArray alloc] init];
    for (int suit = 0; suit < 4; suit++){
        for (int rank = 0; rank < 13; rank++){
            [self.deck addObject:[Card cardWithRank:rank andSuit:suit]];
        }
    }
}

- (void) shuffleDeck{
    
    if(!self.deck){
        [self getNewDeck];
    }
    
    NSUInteger count = self.deck.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self.deck exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
