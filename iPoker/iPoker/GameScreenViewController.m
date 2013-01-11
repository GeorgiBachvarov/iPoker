//
//  GameScreenViewController.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/8/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "GameScreenViewController.h"

@interface GameScreenViewController ()

@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation GameScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithGameOptions:(GameOptions *)gameOptions{
    self = [self initWithNibName:@"GameScreenViewController" bundle:nil];
    if (self){
        self.gameState = [[GameState alloc] initWithGameOptions: gameOptions? gameOptions : [[GameOptions alloc] init] ];
        self.player = [[HumanPlayer alloc] initWithGameState:self.gameState];
        self.bot = [[PokerBot alloc] initWithGameState:self.gameState];
        [self.gameState getNewDeck];
        [self.gameState shuffleDeck];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewsForPlayerCards = [NSArray arrayWithObjects:self.firstPlayerCard, self.secondPlayerCard, nil];
    self.viewsForBotCards = [NSArray arrayWithObjects:self.firstBotCard, self.secondBotCard, nil];
    self.viewsForCommunityCards = [NSArray arrayWithObjects:self.firstCommunityCard, self.secondCommunityCard, self.thirdCommunityCard, self.forthCommunityCard, self.fifthCommunityCard, nil];
    self.playerNameLabel.text = [NSString stringWithFormat:@"%@:", self.gameState.options.playerName];
    
    [self updateBalanceLabels];
    [self enterRound:RoundPostingBlinds];
    [self enterRound:RoundBettingRound];
}

- (void) enterRound: (Round) round{
    switch (round) {
        case RoundPostingBlinds:
        {
            PlayerAction *botBlind = [self.bot nextAction];
            
            PlayerAction *playerBlind = [self.player placeBlind];
            
            self.gameState.currentPot = self.gameState.playerIsDealer ? playerBlind.amount : botBlind.amount;
            self.gameState.currentRaise = !self.gameState.playerIsDealer ? playerBlind.amount : botBlind.amount;
            
            if (botBlind.amount == 0){
                [self endGame:1];
                return;
            }
            
            if (playerBlind.amount == 0){
                [self endGame:-1];
                return;
            }
            
            [self updatePotLabelForPlayerMoney:playerBlind.amount botMoney:botBlind.amount];
            
            self.gameState.round = RoundBettingRound;
            
            break;
        }
        case RoundBettingRound:
        {
            self.gameState.playerHand = [NSMutableArray arrayWithObjects:[self.gameState.deck objectAtIndex:0],[self.gameState.deck objectAtIndex:1] , nil];
            self.gameState.botHand = [NSMutableArray arrayWithObjects:[self.gameState.deck objectAtIndex:2], [self.gameState.deck objectAtIndex:3], nil];
            [self.gameState.deck removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            
            self.firstBotCard.image = [Card cardBack];
            self.secondBotCard.image = [Card cardBack];
//            self.firstBotCard.image = [[self.gameState.botHand objectAtIndex:0] visualRepresentation];
//            self.secondBotCard.image = [[self.gameState.botHand objectAtIndex:1] visualRepresentation];
            self.firstPlayerCard.image = [[self.gameState.playerHand objectAtIndex:0] visualRepresentation];
            self.secondPlayerCard.image = [[self.gameState.playerHand objectAtIndex:1] visualRepresentation];
            
            if (!self.gameState.playerIsDealer){
                [self updateUIForBotAction:[self.bot nextAction]];
            }
            
            break;
        }
        case RoundTheFlop:
        {
            self.gameState.communityCards = [NSMutableArray arrayWithObjects:[self.gameState.deck objectAtIndex:0], [self.gameState.deck objectAtIndex:1], [self.gameState.deck objectAtIndex:2], nil];
            [self.gameState.deck removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
            
            self.firstCommunityCard.image = [[self.gameState.communityCards objectAtIndex:0] visualRepresentation];
            self.secondCommunityCard.image = [[self.gameState.communityCards objectAtIndex:1] visualRepresentation];
            self.thirdCommunityCard.image = [[self.gameState.communityCards objectAtIndex:2] visualRepresentation];
            
            if (!self.gameState.playerIsDealer){
                [self updateUIForBotAction:[self.bot nextAction]];
            }
            
            break;
        }
        case RoundTheTurn:
        {
            [self.gameState.communityCards addObject:[self.gameState.deck objectAtIndex:0]];
            [self.gameState.deck removeObjectAtIndex:0];
            
            self.forthCommunityCard.image = [[self.gameState.communityCards objectAtIndex:3] visualRepresentation];
            
            break;
        }
        case RoundTheRiver:{
            
            [self.gameState.communityCards addObject:[self.gameState.deck objectAtIndex:0]];
            [self.gameState.deck removeObjectAtIndex:0];
            
            self.fifthCommunityCard.image = [[self.gameState.communityCards objectAtIndex:4] visualRepresentation];
            
            if (!self.gameState.playerIsDealer){
                [self updateUIForBotAction:[self.bot nextAction]];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void) endGame:(NSInteger)playerWins {
    NSLog(@"END GAME. Winner: %@", playerWins > 0 ? @"Player": (playerWins < 0 ? @"Bot" : @"Draw"));
    
    NSString *message;
    if (playerWins > 0){
        message = [NSString stringWithFormat:@"%@ Wins!", self.player.name];
    }
    if (playerWins < 0){
        message = @"iPoker Bot Wins!";
    }
    if (playerWins == 0){
        message = @"It's a Draw!";
    }
    
    if (!self.gameState.playerIsAllIn && !self.gameState.botIsAllIn){
        self.player.moneyLeft += playerWins * self.gameState.currentPot;
        self.bot.moneyLeft += -playerWins * self.gameState.currentPot;
    }else{
        if (self.gameState.playerIsAllIn){
            self.bot.moneyLeft += -playerWins * self.player.moneyLeft;
            self.player.moneyLeft += playerWins *self.player.moneyLeft;
        }else{
            self.player.moneyLeft += playerWins *self.bot.moneyLeft;
            self.bot.moneyLeft += -playerWins *self.bot.moneyLeft;
        }
    }
    
    [self updateBalanceLabels];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    alertView.tag = 0;
    [alertView show];
}

- (void) riverShowdown{
    
    self.firstBotCard.image = [[self.gameState.botHand objectAtIndex:0] visualRepresentation];
    self.secondBotCard.image = [[self.gameState.botHand objectAtIndex:1] visualRepresentation];
    
    NSInteger result = [[self.bot evaluateHand:[self.gameState.communityCards arrayByAddingObjectsFromArray:self.gameState.botHand]] compareTo:[self.player evaluateHand:[self.gameState.communityCards arrayByAddingObjectsFromArray:self.gameState.playerHand]]];
    
    [self endGame:-result];
}

- (void) updatePotLabelForPlayerMoney: (NSUInteger)playerPot botMoney: (NSUInteger) botPot{
    self.potLabel.text = [NSString stringWithFormat:@"$ %d / $ %d", playerPot, botPot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)callButtonPressed:(id)sender {
    [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentRaise];
    self.gameState.currentPot = self.gameState.currentRaise;
    
    if (self.gameState.round != RoundTheRiver){
        self.gameState.round ++;
        [self enterRound:self.gameState.round];
        [self updateUIForBotAction:[self.bot nextAction]];
    }else{
        [self riverShowdown];
    }
}



- (IBAction)raiseButtonPressed:(id)sender {
    RaiseViewController *rvc = [[RaiseViewController alloc] initWithDelegate:self];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:rvc];
    [self.popover setPopoverContentSize:CGSizeMake(200, 100)];
    [self.popover presentPopoverFromRect:CGRectMake(0, 0, 200, 100) inView:self.raiseButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    [[rvc numberField] becomeFirstResponder];
}

- (void)raiseViewController:(RaiseViewController *)raiseViewController didChooseSum:(NSUInteger)sum{
    if (sum > self.gameState.currentRaise && sum <= self.player.moneyLeft && sum <= self.gameState.options.moneyLimit){
        self.gameState.currentPot = self.gameState.currentRaise;
        self.gameState.currentRaise = sum;
        [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentPot];
        PlayerAction *botAction = [self.bot nextAction];
        if (botAction.action == ActionCall){
            [self updateUIForBotAction:botAction];
            if (self.gameState.round != RoundTheRiver){
                self.gameState.round++;
                [self enterRound:self.gameState.round];
            }
            else{
                [self riverShowdown];
            }
        }
        if (botAction.action == ActionRaise){
            [self updateUIForBotAction:botAction];
        }
        if (botAction.action == ActionFold){
            self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has folded"];
            [self endGame:1];
        }
    }
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)foldButtonPressed:(id)sender {
    [self endGame:-1];
}

- (IBAction)nextGameButtonPressed:(id)sender {
    self.callButton.hidden = NO;
    self.raiseButton.hidden = NO;
    self.foldButton.hidden = NO;
    self.nextGameButton.hidden = YES;
    self.logLabel.text = @"";
    
    for (UIImageView *cardImageView in [[self.viewsForBotCards arrayByAddingObjectsFromArray:self.viewsForPlayerCards] arrayByAddingObjectsFromArray:self.viewsForCommunityCards]) {
        cardImageView.image = nil;
    }
    
    [self.gameState prepareForNextGame];
    
    [self enterRound:RoundPostingBlinds];
    [self enterRound:RoundBettingRound];
    
}

- (IBAction)allInButtonPressed:(id)sender {
    
    self.gameState.playerIsAllIn = YES;
    
    while (self.gameState.communityCards.count != 5) {
        [self.gameState.communityCards addObject:[self.gameState.deck objectAtIndex:0]];
        [self.gameState.deck removeObjectAtIndex:0];
        ((UIImageView *)[self.viewsForCommunityCards objectAtIndex:self.gameState.communityCards.count - 1]).image = [self.gameState.communityCards objectAtIndex:self.gameState.communityCards.count -1];
    }
    
    [self riverShowdown];
    
}

- (void) updateUIForBotAction: (PlayerAction *) botAction{
    switch (botAction.action) {
        case ActionFold:
            [self endGame:1];
            break;
        case ActionCall:
            if (self.gameState.currentPot != self.gameState.currentRaise){
                self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has called your bet of $ %d", self.gameState.currentRaise];
                self.gameState.currentPot = self.gameState.currentRaise;
            }else{
                self.logLabel.text = @"iPokerBot has checked";
            }
            [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentPot];
            [self.callButton setTitle:@"Check" forState:UIControlStateNormal];
            self.foldButton.hidden = YES;
            break;
        case ActionRaise:
            self.gameState.currentPot = self.gameState.currentRaise;
            self.gameState.currentRaise = botAction.amount;
             self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has raised the bet to $ %d", self.gameState.currentRaise];
            [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentRaise];
            [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
            self.foldButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (void) updateBalanceLabels{
    self.moneyLeftLabel.text = [NSString stringWithFormat:@"$ %d", self.player.moneyLeft];
    self.botMoneyLeftLabel.text = [NSString stringWithFormat:@"$ %d", self.bot.moneyLeft];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    self.nextGameButton.hidden = NO;
    self.callButton.hidden = YES;
    self.raiseButton.hidden = YES;
    self.foldButton.hidden = YES;
}

@end
