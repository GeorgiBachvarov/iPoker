//
//  GameScreenViewController.h
//  iPoker
//
//  Created by Georgi Bachvarov on 1/8/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameState.h"
#import "HumanPlayer.h"
#import "PokerBot.h"
#import "RaiseViewController.h"

@interface GameScreenViewController : UIViewController <RaiseViewControllerDelegate, UIAlertViewDelegate, PokerBotDelegate>

- initWithGameOptions: (GameOptions *) gameOptions;

@property (nonatomic, strong) GameState *gameState;
@property (nonatomic, strong) HumanPlayer *player;
@property (nonatomic, strong) PokerBot *bot;

@property (weak, nonatomic) IBOutlet UIImageView *firstPlayerCard;
@property (weak, nonatomic) IBOutlet UIImageView *secondPlayerCard;
@property (weak, nonatomic) IBOutlet UIImageView *firstBotCard;
@property (weak, nonatomic) IBOutlet UIImageView *secondBotCard;
@property (weak, nonatomic) IBOutlet UIImageView *firstCommunityCard;
@property (weak, nonatomic) IBOutlet UIImageView *secondCommunityCard;
@property (weak, nonatomic) IBOutlet UIImageView *thirdCommunityCard;
@property (weak, nonatomic) IBOutlet UIImageView *forthCommunityCard;
@property (weak, nonatomic) IBOutlet UIImageView *fifthCommunityCard;
@property (weak, nonatomic) IBOutlet UILabel *moneyLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *botMoneyLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *potLabel;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *raiseButton;
@property (weak, nonatomic) IBOutlet UIButton *foldButton;
@property (weak, nonatomic) IBOutlet UIButton *nextGameButton;
@property (weak, nonatomic) IBOutlet UIButton *allInButton;

@property (nonatomic, strong) NSArray *viewsForPlayerCards;
@property (nonatomic, strong) NSArray *viewsForBotCards;
@property (nonatomic, strong) NSArray *viewsForCommunityCards;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)callButtonPressed:(id)sender;
- (IBAction)raiseButtonPressed:(id)sender;
- (IBAction)foldButtonPressed:(id)sender;
- (IBAction)nextGameButtonPressed:(id)sender;
- (IBAction)allInButtonPressed:(id)sender;

- (void)raiseViewController:(RaiseViewController *)raiseViewController didChooseSum:(NSUInteger)sum;

@end
