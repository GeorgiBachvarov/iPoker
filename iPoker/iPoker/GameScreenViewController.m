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
        self.gameState = [[GameState alloc] initWithGameOptions:[[GameOptions alloc] init]];
        self.player = [[HumanPlayer alloc] initWithGameState:self.gameState];
        self.bot = [[PokerBot alloc] initWithGameState:self.gameState];
        self.player.isDealer = self.gameState.playerIsDealer;
        self.bot.isDealer = !self.player.isDealer;
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
                [self endGame:YES];
                return;
            }
            
            if (playerBlind.amount == 0){
                [self endGame:NO];
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
            self.firstPlayerCard.image = [[self.gameState.playerHand objectAtIndex:0] visualRepresentation];
            self.secondPlayerCard.image = [[self.gameState.playerHand objectAtIndex:1] visualRepresentation];
            
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

- (void) endGame:(BOOL)playerWins {
    NSLog(@"END GAME");
}

- (void) riverShowdown{
    
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
    if (sum > self.gameState.currentRaise){
        self.gameState.currentPot = self.gameState.currentRaise;
        self.gameState.currentRaise = sum;
        [self updatePotLabelForPlayerMoney:self.gameState.currentRaise botMoney:self.gameState.currentPot];
    }
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)foldButtonPressed:(id)sender {
    [self endGame:NO];
}
@end
