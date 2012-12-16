//
//  HumanPlayer.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "HumanPlayer.h"

@implementation HumanPlayer

- (NSArray *)availableCards{
    NSMutableArray *cards = [NSMutableArray array];
    [cards addObjectsFromArray:self.gameState.communityCards];
    [cards addObjectsFromArray:self.gameState.playerHand];
    return cards;
}


@end
