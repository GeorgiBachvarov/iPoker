//
//  PlayerAction.h
//  iPoker
//
//  Created by Georgi Bachvarov on 12/16/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActionFold = 0,
    ActionCall = 1,
    ActionRaise = 2,
    ActionPostBlind = 3
} Action;

@interface PlayerAction : NSObject

@property (nonatomic, assign) Action action;
@property (nonatomic, assign) NSInteger amount;

@end
