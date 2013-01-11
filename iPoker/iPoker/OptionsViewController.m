//
//  OptionsViewController.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/11/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()

@property (nonatomic, assign) NSUInteger playerMoney;
@property (nonatomic, assign) NSUInteger minimumBet;
@property (nonatomic, assign) NSUInteger maximumBet;
@property (nonatomic, strong) NSString *playerName;


@end

@implementation OptionsViewController


- (id)initWithInitialOptions:(GameOptions *)options{
    self = [self initWithNibName:@"OptionsViewController" bundle:nil];
    if (self){
        self.playerMoney = options.startingMoney;
        self.minimumBet = options.minimumBet;
        self.maximumBet = options.moneyLimit;
        self.playerName = options.playerName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.minimumBetStepper.stepValue = 10;
    self.minimumBetStepper.minimumValue = 0;
    self.minimumBetStepper.maximumValue = NSIntegerMax;
    self.minimumBetStepper.value = self.minimumBet;
    
    self.maximumBetStepper.stepValue = 10;
    self.maximumBetStepper.minimumValue = 0;
    self.maximumBetStepper.maximumValue = NSIntegerMax;
    self.maximumBetStepper.value = self.maximumBet;
    
    self.startingMoneyStepper.stepValue = 10;
    self.startingMoneyStepper.minimumValue = 0;
    self.startingMoneyStepper.maximumValue = NSIntegerMax;
    self.startingMoneyStepper.value = self.playerMoney;
    
    self.playerNameTextField.text = self.playerName;
    self.minimumBetLabel.text = [NSString stringWithFormat:@"Minimum Bet: $ %d", self.minimumBet];
    self.maximumBetLabel.text = [NSString stringWithFormat:@"Maximum Bet: $ %d", self.maximumBet];
    self.startingMoneyLabel.text = [NSString stringWithFormat:@"Starting Money: $ %d", self.playerMoney];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startingMoneyValueChanged:(id)sender {
    self.playerMoney = (int)self.startingMoneyStepper.value;
    self.startingMoneyLabel.text = [NSString stringWithFormat:@"Starting Money: $ %d", self.playerMoney];
}

- (IBAction)minimumBetChanged:(id)sender {
    self.minimumBet = (int)self.minimumBetStepper.value;
    self.minimumBetLabel.text = [NSString stringWithFormat:@"Minimum Bet: $ %d", self.minimumBet];
}

- (IBAction)maximumBetChanged:(id)sender {
    self.maximumBet = (int)self.maximumBetStepper.value;
    self.maximumBetLabel.text = [NSString stringWithFormat:@"Maximum Bet: $ %d", self.maximumBet];
}

- (IBAction)saveButtonPressed:(id)sender {
    
    if ([self validation]){
        GameOptions *options = [[GameOptions alloc] init];
        options.playerName = self.playerName;
        options.moneyLimit = self.maximumBet;
        options.minimumBet = self.minimumBet;
        options.startingMoney = self.playerMoney;
        [self.delegate optionsViewController:self choseGameOptions:options];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.delegate optionsViewController:self choseGameOptions:nil];
}

- (IBAction)playerNameTextFiledDidEndEditing:(id)sender {
    [self.playerNameTextField resignFirstResponder];
    self.playerName = self.playerNameTextField.text;
}

- (BOOL) validation{
    BOOL valid = YES;
    
    if (self.minimumBet > self.maximumBet) {
        valid = NO;
    }
    
    if (self.minimumBet > self.playerMoney) {
        valid = NO;
    }
    
    return valid;
}

@end
