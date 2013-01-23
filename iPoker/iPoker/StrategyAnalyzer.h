//
//  StrategyAnalyzer.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/18/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandStrength.h"

typedef enum {
    StrategyUndefined,
    StrategyValueBet,
    StrategyBluff,
    StrategySlowPlay
} Strategy;

@interface StrategyAnalyzer : NSObject

+ (NSDictionary *) strategiesForRounds: (NSDictionary *) playerActions basedOnCards: (NSArray *) cards;

+ (CGFloat) initialWinCoefficientForHand: (NSArray *)cards;

+ (HandStrength *) evaluateHand: (NSArray *) hand;

@end
