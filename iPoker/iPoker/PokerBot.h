//
//  PokerBot.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@protocol PokerBotDelegate <NSObject>

- (void) botChoseAction: (PlayerAction *) action;

@end

@interface PokerBot : Player

- (CGFloat) handStrengthCoefficient: (HandStrength *) handStrength forRound:(Round) round;
-(void) nextAction;
@property (nonatomic, assign) id <PokerBotDelegate> delegate;

@end
