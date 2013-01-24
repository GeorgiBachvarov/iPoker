//
//  MainScreenViewController.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/8/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameScreenViewController.h"
#import "OptionsViewController.h"

@interface MainScreenViewController : UIViewController <OptionsViewControllerDelegate>

- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)newGameButtonPressed:(id)sender;

@property (nonatomic, strong) GameOptions *gameOptions;

@end
