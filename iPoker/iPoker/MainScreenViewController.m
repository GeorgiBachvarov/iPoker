//
//  MainScreenViewController.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/8/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "MainScreenViewController.h"

#define USER_DEFAULTS_KEY_PLAYERNAME @"playerName"
#define USER_DEFAULTS_KEY_PLAYERMONEY @"playerMoney"
#define USER_DEFAULTS_KEY_MINIMUMBET @"minimumBet"
#define USER_DEFAULTS_KEY_MAXIMUMBET @"maximumBet"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gameOptions = [[GameOptions alloc] init];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.gameOptions.playerName = [userDefaults objectForKey:USER_DEFAULTS_KEY_PLAYERNAME];
        self.gameOptions.minimumBet = [[userDefaults objectForKey:USER_DEFAULTS_KEY_MINIMUMBET] integerValue];
        self.gameOptions.moneyLimit = [[userDefaults objectForKey:USER_DEFAULTS_KEY_MAXIMUMBET] integerValue];
        self.gameOptions.startingMoney = [[userDefaults objectForKey:USER_DEFAULTS_KEY_PLAYERMONEY] integerValue];
        
        if (!self.gameOptions.playerName){
            self.gameOptions.playerName = DEFAULT_PLAYER_NAME;
        }
        if (!self.gameOptions.minimumBet){
            self.gameOptions.minimumBet = DEFAULT_MINIMUM_BET;
        }
        if (!self.gameOptions.moneyLimit){
            self.gameOptions.moneyLimit = DEFAULT_MONEY_LIMIT;
        }
        if (!self.gameOptions.startingMoney){
            self.gameOptions.startingMoney = DEFAULT_PLAYER_MONEY;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGameButtonPressed:(id)sender {
    GameScreenViewController *gameController = [[GameScreenViewController alloc] initWithGameOptions:self.gameOptions];
    [self presentViewController:gameController animated:YES completion:nil];
}

- (IBAction)optionsButtonPressed:(id)sender {
    OptionsViewController *optionsController = [[OptionsViewController alloc] initWithInitialOptions:self.gameOptions];
    optionsController.delegate = self;
    [self presentViewController:optionsController animated:YES completion:nil];
}

- (void)optionsViewController:(OptionsViewController *)optionsViewController choseGameOptions:(GameOptions *)gameOptions{
    if (gameOptions){
        self.gameOptions = gameOptions;
        [self saveOptionsToUserDefaults];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveOptionsToUserDefaults{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.gameOptions.playerName forKey:USER_DEFAULTS_KEY_PLAYERNAME];
    [userDefaults setObject:@(self.gameOptions.minimumBet) forKey:USER_DEFAULTS_KEY_MINIMUMBET];
    [userDefaults setObject:@(self.gameOptions.moneyLimit) forKey:USER_DEFAULTS_KEY_MAXIMUMBET];
    [userDefaults setObject:@(self.gameOptions.startingMoney) forKey:USER_DEFAULTS_KEY_PLAYERMONEY];
}

@end
