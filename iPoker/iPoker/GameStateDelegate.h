//
//  GameStateDelegate.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/7/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GameStateDelegate <NSObject>

- (void) gameEndedWithResult: (NSInteger) winner playerStrategy: (NSDictionary *) strategy;

@end
