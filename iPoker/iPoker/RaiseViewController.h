//
//  RaiseViewController.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/9/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RaiseViewController;
@protocol RaiseViewControllerDelegate <NSObject>

- (void) raiseViewController: (RaiseViewController *) raiseViewController didChooseSum: (NSUInteger) sum;

@end

@interface RaiseViewController : UIViewController

@property (nonatomic, strong) UITextField *numberField;
@property (nonatomic, strong) UIButton *raiseButton;
@property (nonatomic, assign) id <RaiseViewControllerDelegate> delegate;

- initWithDelegate: (id <RaiseViewControllerDelegate>) delegate;



@end
