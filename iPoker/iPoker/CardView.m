//
//  CardView.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/8/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCard:(Card *)card{
    self = [super init];
    if (self){
        self.bounds = CGRectMake(0, 0, 80, 140);
        self.image = [card visualRepresentation];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
