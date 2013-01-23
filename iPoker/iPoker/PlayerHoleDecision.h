//
//  PlayerHoleDecision.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/18/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlayerHoleDecision : NSManagedObject

@property (nonatomic, retain) NSNumber * firstCard;
@property (nonatomic, retain) NSNumber * secondCard;
@property (nonatomic, retain) NSNumber * suited;
@property (nonatomic, retain) NSNumber * strategy;

@end
