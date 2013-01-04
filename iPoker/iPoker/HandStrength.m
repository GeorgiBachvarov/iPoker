//
//  HandStrength.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "HandStrength.h"

@implementation HandStrength

- (NSInteger)compareTo:(HandStrength *)otherHand{
    if (self.handRanking > otherHand.handRanking){
        return 1;
    }
    
    if (self.handRanking < otherHand.handRanking){
        return -1;
    }
    
    if (self.handRanking == otherHand.handRanking){
        if (self.highCard > otherHand.highCard){
            return 1;
        }
        if (self.highCard < otherHand.highCard){
            return -1;
        }
    }
    
    return 0;
}

@end
