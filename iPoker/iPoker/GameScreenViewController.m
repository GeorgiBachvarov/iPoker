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
        self.bot.delegate = self;
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
}

- (void) enterRound: (Round) round{
    switch (round) {
        case RoundPostingBlinds:
        {
            
            if (self.gameState.playerIsDealer){
               PlayerAction *playerBlind = [self.player placeBlind];
                self.gameState.currentPot = playerBlind.amount;
                
                if (playerBlind.amount == 0){
                    [self endGame:-1];
                    return;
                }
            }
            
            [self.bot nextAction];
            
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
                [self.bot nextAction];
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
            
            break;
        }
            
        default:
            break;
    }
}

- (void) endGame:(NSInteger)playerWins {
    
    self.allInButton.hidden = YES;
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
    
    if (self.player.moneyLeft == 0 || self.bot.moneyLeft == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Game Over. You %@!", self.player.moneyLeft == 0? @"Lose" : @"Win"] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        alertView.tag = 1;
        [alertView show];
        return;
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    alertView.tag = 0;
    [alertView show];
}

- (void) riverShowdown{
    
    self.firstBotCard.image = [[self.gameState.botHand objectAtIndex:0] visualRepresentation];
    self.secondBotCard.image = [[self.gameState.botHand objectAtIndex:1] visualRepresentation];
    
    NSInteger result = [[StrategyAnalyzer evaluateHand:[self.gameState.communityCards arrayByAddingObjectsFromArray:self.gameState.botHand]] compareTo:[StrategyAnalyzer evaluateHand:[self.gameState.communityCards arrayByAddingObjectsFromArray:self.gameState.playerHand]]];
    
    
    [self.bot gameEndedWithResult:-result playerStrategy:[StrategyAnalyzer strategiesForRounds:self.gameState.playerActionsByRound basedOnCards:[self.gameState.playerHand arrayByAddingObjectsFromArray:self.gameState.communityCards]]];
    
    [self endGame:-result];
}

- (void) updatePotLabelForPlayerMoney: (NSUInteger)playerPot botMoney: (NSUInteger) botPot{
    NSLog(@"$ %d / $ %d", playerPot, botPot);
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
    [self logPlayerAction:ActionCall];
    [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentRaise];
    BOOL isCheck = self.gameState.currentPot == self.gameState.currentRaise;
    self.gameState.currentPot = self.gameState.currentRaise;
    
    
    if (self.gameState.playerIsDealer){
        if (self.gameState.round != RoundTheRiver){
            self.gameState.round ++;
            [self enterRound:self.gameState.round];
            [self.bot nextAction];
        }else{
            [self riverShowdown];
        }
    }else{
        if (!isCheck || self.gameState.round == RoundBettingRound || self.gameState.currentRaise == self.gameState.options.moneyLimit){
            if (self.gameState.round != RoundTheRiver){
                [self.callButton setTitle:@"Check" forState:UIControlStateNormal];
                self.foldButton.hidden = YES;
                self.gameState.round ++;
                [self enterRound:self.gameState.round];
                
            }else{
                [self riverShowdown];
            }
        }
        if (isCheck){
            [self.bot nextAction];
        }
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
        [self logPlayerAction:ActionRaise];
        self.gameState.currentPot = self.gameState.currentRaise;
        self.gameState.currentRaise = sum;
        [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentPot];
        [self.bot nextAction];
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
//    [self enterRound:RoundBettingRound];
    
}

- (IBAction)allInButtonPressed:(id)sender {
    
    self.gameState.playerIsAllIn = YES;
    
    self.gameState.currentPot = self.player.moneyLeft;
    
    [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentRaise];
    
    [self dealToEnd];
    
    [self riverShowdown];
    
}

- (void) dealToEnd{
    while (self.gameState.communityCards.count != 5) {
        [self.gameState.communityCards addObject:[self.gameState.deck objectAtIndex:0]];
        [self.gameState.deck removeObjectAtIndex:0];
        ((UIImageView *)[self.viewsForCommunityCards objectAtIndex:self.gameState.communityCards.count - 1]).image = [[self.gameState.communityCards objectAtIndex:self.gameState.communityCards.count -1] visualRepresentation];
    }
}

- (void) updateUIForBotAction: (PlayerAction *) botAction{
    
    switch (botAction.action) {
        case ActionPostBlind:{
            if (botAction.amount == 0){
                [self endGame:1];
                return;
            }
            
            if (self.gameState.playerIsDealer){
                self.gameState.currentRaise = botAction.amount;
                [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentRaise];
                self.gameState.round = RoundBettingRound;
                [self enterRound:RoundBettingRound];
            }else{
                PlayerAction *playerBlind = [self.player placeBlind];
                self.gameState.currentRaise = playerBlind.amount;
                self.gameState.currentPot = botAction.amount;
                
                [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentPot];
                
                if (playerBlind.amount == 0){
                    [self endGame:-1];
                    return;
                }
                
                self.gameState.round ++;
                [self enterRound:self.gameState.round];
            }

            
            break;
        }
        case ActionFold:
            self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has folded"];
            [self endGame:1];
            break;
        case ActionCall:{
            if (self.gameState.currentPot != self.gameState.currentRaise){
                self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has called your bet of $ %d", self.gameState.currentRaise];
                self.gameState.currentPot = self.gameState.currentRaise;
            }else{
                self.logLabel.text = @"iPokerBot has checked";
            }
            [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentPot];
            [self.callButton setTitle:@"Check" forState:UIControlStateNormal];
            self.foldButton.hidden = YES;
            if (!self.gameState.playerIsDealer){
                if (self.gameState.round != RoundTheRiver){
                    self.gameState.round++;
                    [self enterRound:self.gameState.round];
                }
                else{
                    [self riverShowdown];
                }
            }
            break;
        }
        case ActionRaise:
            NSLog(@"update uifor action raise");
            self.gameState.currentPot = self.gameState.currentRaise;
            self.gameState.currentRaise = botAction.amount;
             self.logLabel.text = [NSString stringWithFormat: @"iPokerBot has raised the bet to $ %d", self.gameState.currentRaise];
            [self updatePotLabelForPlayerMoney:self.gameState.currentPot botMoney:self.gameState.currentRaise];
            [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
            self.foldButton.hidden = NO;
            if (self.gameState.currentRaise >= self.player.moneyLeft){
                self.allInButton.hidden = NO;
                self.callButton.hidden = YES;
            }
            break;
        case ActionAllIn:
            self.gameState.botIsAllIn = YES;
            self.gameState.currentPot = self.bot.moneyLeft;
            [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentPot];
            [self dealToEnd];
            [self riverShowdown];
            break;
        default:
            break;
    }
    
}

- (void) updateBalanceLabels{
    self.moneyLeftLabel.text = [NSString stringWithFormat:@"$ %d", self.player.moneyLeft];
    self.botMoneyLeftLabel.text = [NSString stringWithFormat:@"$ %d", self.bot.moneyLeft];
}

- (void) logPlayerAction: (Action) playerAction{
    Round round = self.gameState.round;
    [[self.gameState.playerActionsByRound objectForKey:@(round)]  addObject:@(playerAction)];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 0:
            self.nextGameButton.hidden = NO;
            self.callButton.hidden = YES;
            self.raiseButton.hidden = YES;
            self.foldButton.hidden = YES;
            break;
        case 1:
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}


#pragma mark PokerBotDelegate

- (void)botChoseAction:(PlayerAction *)action{
    [self updateUIForBotAction:action];
}

@end
