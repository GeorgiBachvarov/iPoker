//
//  OptionsViewController.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/11/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameOptions.h"

@class OptionsViewController;
@protocol OptionsViewControllerDelegate <NSObject>

- (void) optionsViewController: (OptionsViewController *) optionsViewController choseGameOptions: (GameOptions *) gameOptions;

@end

@interface OptionsViewController : UIViewController

- initWithInitialOptions: (GameOptions *) options;

@property (assign, nonatomic) id <OptionsViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *playerNameTextField;
@property (weak, nonatomic) IBOutlet UIStepper *startingMoneyStepper;
@property (weak, nonatomic) IBOutlet UIStepper *minimumBetStepper;
@property (weak, nonatomic) IBOutlet UIStepper *maximumBetStepper;
@property (weak, nonatomic) IBOutlet UILabel *startingMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumBetLabel;
@property (weak, nonatomic) IBOutlet UILabel *maximumBetLabel;

- (IBAction)startingMoneyValueChanged:(id)sender;
- (IBAction)minimumBetChanged:(id)sender;
- (IBAction)maximumBetChanged:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)playerNameTextFiledDidEndEditing:(id)sender;

@end
