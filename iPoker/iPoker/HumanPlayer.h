//
//  HumanPlayer.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface HumanPlayer : Player

- (PlayerAction *) placeBlind;

@end
