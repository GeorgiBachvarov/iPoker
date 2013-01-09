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

- (PlayerAction *)placeBlind{
    
    PlayerAction *blindAction = [[PlayerAction alloc] init];
    blindAction.action = ActionPostBlind;
    
    if (self.isDealer){
        if (self.moneyLeft >= self.gameState.options.minimumBet / 2){
            blindAction.amount = self.gameState.options.minimumBet / 2;
        }else{
            blindAction.amount = 0;
            NSLog(@"Minimum bet: %d, money left: %d. Cannot post blind", self.gameState.options.minimumBet, self.moneyLeft);
        }
    }else{
        if (self.moneyLeft >= self.gameState.options.minimumBet){
            blindAction.amount = self.gameState.options.minimumBet;
        }else{
            blindAction.amount = 0;
            NSLog(@"Minimum bet: %d, money left: %d. Cannot post blind", self.gameState.options.minimumBet, self.moneyLeft);
        }
    }
    
    return blindAction;
}

- (id)initWithGameState:(GameState *)state{
    self = [super initWithGameState:state];
    if (self){
        state.player = self;
    }
    return self;
}

@end
