//
//  Player.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "Player.h"

@implementation Player

- (void)gameEndedWithResult:(NSInteger)winner playerStrategy:(NSDictionary *)strategy{
    
}


- (id)initWithGameState:(GameState *)state{
    self = [self init];
    if (self){
        self.gameState = state;
        self.moneyLeft = state.options.startingMoney;
    }
    return self;
}

- (NSArray *)availableCards{
    return  nil;
}




@end
