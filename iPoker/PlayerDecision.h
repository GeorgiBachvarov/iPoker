//
//  PlayerDecision.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/18/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlayerDecision : NSManagedObject

@property (nonatomic, retain) NSNumber * ranking;
@property (nonatomic, retain) NSNumber * highCard;
@property (nonatomic, retain) NSNumber * strategy;
@property (nonatomic, retain) NSNumber * round;

@end
