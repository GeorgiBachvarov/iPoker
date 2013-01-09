//
//  PokerBot.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "PokerBot.h"

@interface PokerBot (){
    
}

@property (nonatomic, assign) CGFloat aggression;

@end

@implementation PokerBot

- (id)initWithGameState:(GameState *)state {
    self = [super initWithGameState:state];
    if (self){
        self.aggression = 0.5;
        state.bot = self;
    }
    return self;
}

- (NSArray *)availableCards{
    NSMutableArray *cards = [NSMutableArray array];
    [cards addObjectsFromArray:self.gameState.communityCards];
    [cards addObjectsFromArray:self.gameState.botHand];
    return cards;
}

- (PlayerAction *)nextAction{
    PlayerAction *botAction = [[PlayerAction alloc] init];
    
    //posting blinds
    if (self.gameState.round == RoundPostingBlinds){
        if (self.isDealer){
            if (self.moneyLeft >= self.gameState.options.minimumBet / 2){
                botAction.action = ActionPostBlind;
                botAction.amount = self.gameState.options.minimumBet / 2;
            }else{
                botAction.action = ActionPostBlind;
                botAction.amount = 0;
                NSLog(@"Minimum bet: %d, money left: %d. Cannot post blind", self.gameState.options.minimumBet, self.moneyLeft);
            }
        }else{
            if (self.moneyLeft >= self.gameState.options.minimumBet){
                botAction.action = ActionPostBlind;
                botAction.amount = self.gameState.options.minimumBet;
            }else{
                botAction.action = ActionPostBlind;
                botAction.amount = 0;
                NSLog(@"Minimum bet: %d, money left: %d. Cannot post blind", self.gameState.options.minimumBet, self.moneyLeft);
            }
        }
    }
    
    //initial betting round (when there are no community cards on the table)
    if (self.gameState.round == RoundBettingRound){
        
        CGFloat objectiveWinCoefficient = [self initialWinCoefficient];
        
        if (objectiveWinCoefficient > 0.5){
            
            botAction.action = ActionRaise;
            
            NSUInteger amountToRaise = self.gameState.currentRaise + (uint)(self.aggression * (float)self.gameState.currentRaise);
            
            if (amountToRaise > self.moneyLeft){
                amountToRaise = self.moneyLeft;
            }
            
            if (amountToRaise > self.gameState.options.moneyLimit){
                amountToRaise = self.gameState.options.moneyLimit;
            }
            
            botAction.amount = amountToRaise;
            
        }else{
            
            if (objectiveWinCoefficient + self.aggression > 1){
                
                botAction.action = ActionRaise;
                
                NSUInteger amountToRaise = self.gameState.currentRaise + (uint)(self.aggression * (float)self.gameState.currentRaise);
                
                if (amountToRaise > self.moneyLeft){
                    amountToRaise = self.moneyLeft;
                }
                
                if (amountToRaise > self.gameState.options.moneyLimit){
                    amountToRaise = self.gameState.options.moneyLimit;
                }
                
                botAction.amount = amountToRaise;
                
                
            }else if (objectiveWinCoefficient + self.aggression > 0.85){
                botAction.action = ActionCall;
                botAction.amount = self.gameState.currentRaise;
            }else{
                botAction.action = ActionFold;
                botAction.amount = self.gameState.currentPot;
            }
        }
    }
    
    //any of the other three rounds Flop/Turn/River
    if (self.gameState.round > RoundBettingRound){
        HandStrength *handStrength = [self evaluateHand: [self availableCards]];
        CGFloat handStrengthCoefficient = [self handStrengthCoefficient:handStrength forRound:self.gameState.round];
        
        if (handStrengthCoefficient + self.aggression > 1){
            
            botAction.action = ActionRaise;
            
            NSUInteger amountToRaise = self.gameState.currentRaise + (uint)(self.aggression * (float)self.gameState.currentRaise);
            
            if (amountToRaise > self.moneyLeft){
                amountToRaise = self.moneyLeft;
            }
            
            if (amountToRaise > self.gameState.options.moneyLimit){
                amountToRaise = self.gameState.options.moneyLimit;
            }
            
            botAction.amount = amountToRaise;
            
        }else{
            
            if (handStrengthCoefficient + self.aggression > 1){
                
                botAction.action = ActionRaise;
                
                NSUInteger amountToRaise = self.gameState.currentRaise + (uint)(self.aggression * (float)self.gameState.currentRaise);
                
                if (amountToRaise > self.moneyLeft){
                    amountToRaise = self.moneyLeft;
                }
                
                if (amountToRaise > self.gameState.options.moneyLimit){
                    amountToRaise = self.gameState.options.moneyLimit;
                }
                
                botAction.amount = amountToRaise;
                
                
            }else if (handStrengthCoefficient + self.aggression > 0.85){
                botAction.action = ActionCall;
                botAction.amount = self.gameState.currentRaise;
            }else{
                botAction.action = ActionFold;
                botAction.amount = self.gameState.currentPot;
            }
            
        }
    }
    
    if (botAction.amount > self.moneyLeft){
        //indicates the bot is out of money and can't continue - happens only when forced to fold or call
        botAction.action = ActionFold;
        botAction.amount = 0;
    }
    
    return botAction;
}

- (CGFloat) handStrengthCoefficient: (HandStrength *) handStrength forRound:(Round) round{
    CGFloat strength = (float)(4 - round) / 5;
    
    switch (handStrength.handRanking) {
        case HandRankingNone:
            strength += 0.05;
            break;
        case HandRankingOnePair:
            strength += 0.1;
            break;
        case HandRankingTwoPair:
            strength += 0.2;
            break;
        case HandRankingThreeOfAKind:
            strength += 0.32;
            break;
        case HandRankingStraight:
            strength += 0.44;
            break;
        case HandRankingFlush:
            strength += 0.56;
            break;
        case HandRankingFullHouse:
            strength += 0.68;
            break;
        case HandRankingFourOfAKind:
            strength += 0.8;
            break;
        case HandRankingStraightFlush:
            strength += 0.88;
            break;
        case HandRankingRoyalFlush:
            strength += 0.88;
            break;
        default:
            break;
    }
    
    strength += (float)handStrength.highCard  /  100;
    
    return strength;
}

- (CGFloat) initialWinCoefficient{
    NSArray *cards = self.gameState.botHand;
    Card *firstCard;
    Card *secondCard;
    
    if ([[cards objectAtIndex:1] rank] > [[cards objectAtIndex:0] rank]){
        firstCard = [cards objectAtIndex:1];
        secondCard = [cards objectAtIndex:0];
    }else{
        firstCard = [cards objectAtIndex:0];
        secondCard = [cards objectAtIndex:1];
    }
    
    switch (firstCard.rank) {
        case CardRankAce:
            switch (secondCard.rank) {
                case CardRankAce:
                    return 0.85;
                case CardRankKing:
                    if (firstCard.suit == secondCard.suit)
                        return 0.67;
                    else
                        return 0.654;
                case CardRankQueen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.661;
                    else
                        return 0.645;
                case CardRankJack:
                    if (firstCard.suit == secondCard.suit)
                        return 0.654;
                    else
                        return 0.636;
                case CardRankTen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.647;
                    else
                        return 0.629;
                case CardRankNine:
                    if (firstCard.suit == secondCard.suit)
                        return 0.63;
                    else
                        return 0.609;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.621;
                    else
                        return 0.601;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.611;
                    else
                        return 0.591;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.6;
                    else
                        return 0.578;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.599;
                    else
                        return 0.577;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.589;
                    else
                        return 0.564;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.58;
                    else
                        return 0.556;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.57;
                    else
                        return 0.546;
                default:
                    return 0;
            }
        case CardRankKing:
            switch (secondCard.rank) {
                case CardRankKing:
                    return 0.824;
                case CardRankQueen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.634;
                    else
                        return 0.614;
                case CardRankJack:
                    if (firstCard.suit == secondCard.suit)
                        return 0.626;
                    else
                        return 0.606;
                case CardRankTen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.619;
                    else
                        return 0.599;
                case CardRankNine:
                    if (firstCard.suit == secondCard.suit)
                        return 0.6;
                    else
                        return 0.58;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.585;
                    else
                        return 0.563;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.578;
                    else
                        return 0.554;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.568;
                    else
                        return 0.543;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.558;
                    else
                        return 0.533;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.547;
                    else
                        return 0.521;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.538;
                    else
                        return 0.512;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.529;
                    else
                        return 0.502;
                default:
                    return 0;
            }
        case CardRankQueen:
            switch (secondCard.rank) {
                case CardRankQueen:
                    return 0.799;
                case CardRankJack:
                    if (firstCard.suit == secondCard.suit)
                        return 0.603;
                    else
                        return 0.582;
                case CardRankTen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.595;
                    else
                        return 0.574;
                case CardRankNine:
                    if (firstCard.suit == secondCard.suit)
                        return 0.579;
                    else
                        return 0.555;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.562;
                    else
                        return 0.538;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.545;
                    else
                        return 0.519;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.538;
                    else
                        return 0.511;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.529;
                    else
                        return 0.502;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.517;
                    else
                        return 0.49;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.507;
                    else
                        return 0.479;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.499;
                    else
                        return 0.47;
                default:
                    return 0;
            }
        case CardRankJack:
            switch (secondCard.rank) {
                    return 0.775;
                case CardRankTen:
                    if (firstCard.suit == secondCard.suit)
                        return 0.575;
                    else
                        return 0.554;
                case CardRankNine:
                    if (firstCard.suit == secondCard.suit)
                        return 0.558;
                    else
                        return 0.534;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.542;
                    else
                        return 0.517;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.524;
                    else
                        return 0.499;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.508;
                    else
                        return 0.479;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.5;
                    else
                        return 0.471;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.49;
                    else
                        return 0.461;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.479;
                    else
                        return 0.45;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.471;
                    else
                        return 0.44;
                default:
                    return 0;
            }
        case CardRankTen:
            switch (secondCard.rank) {
                case CardRankTen:
                    return 0.751;
                case CardRankNine:
                    if (firstCard.suit == secondCard.suit)
                        return 0.543;
                    else
                        return 0.517;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.526;
                    else
                        return 0.5;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.51;
                    else
                        return 0.482;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.492;
                    else
                        return 0.463;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.472;
                    else
                        return 0.442;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.464;
                    else
                        return 0.434;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.455;
                    else
                        return 0.424;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.447;
                    else
                        return 0.415;
                default:
                    return 0;
            }
        case CardRankNine:
            switch (secondCard.rank) {
                case CardRankNine:
                    return 0.721;
                case CardRankEight:
                    if (firstCard.suit == secondCard.suit)
                        return 0.511;
                    else
                        return 0.484;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.495;
                    else
                        return 0.467;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.477;
                    else
                        return 0.449;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.459;
                    else
                        return 0.429;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.438;
                    else
                        return 0.407;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.432;
                    else
                        return 0.399;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.423;
                    else
                        return 0.389;
                default:
                    return 0;
            }
        case CardRankEight:
            switch (secondCard.rank) {
                case CardRankEight:
                    return 0.691;
                case CardRankSeven:
                    if (firstCard.suit == secondCard.suit)
                        return 0.482;
                    else
                        return 0.455;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.465;
                    else
                        return 0.436;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.448;
                    else
                        return 0.417;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.427;
                    else
                        return 0.396;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.408;
                    else
                        return 0.375;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.403;
                    else
                        return 0.368;
                default:
                    return 0;
            }
        case CardRankSeven:
            switch (secondCard.rank) {
                case CardRankSeven:
                    return 0.662;
                case CardRankSix:
                    if (firstCard.suit == secondCard.suit)
                        return 0.457;
                    else
                        return 0.427;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.438;
                    else
                        return 0.408;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.418;
                    else
                        return 0.386;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.4;
                    else
                        return 0.366;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.381;
                    else
                        return 0.346;
                default:
                    return 0;
            }
        case CardRankSix:
            switch (secondCard.rank) {
                case CardRankSix:
                    return 0.633;
                case CardRankFive:
                    if (firstCard.suit == secondCard.suit)
                        return 0.432;
                    else
                        return 0.401;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.414;
                    else
                        return 0.38;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.394;
                    else
                        return 0.359;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.375;
                    else
                        return 0.34;
                default:
                    return 0;
            }
        case CardRankFive:
            switch (secondCard.rank) {
                case CardRankFive:
                    return 0.603;
                case CardRankFour:
                    if (firstCard.suit == secondCard.suit)
                        return 0.411;
                    else
                        return 0.379;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.393;
                    else
                        return 0.358;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.375;
                    else
                        return 0.339;
                default:
                    return 0;
            }
        case CardRankFour:
            switch (secondCard.rank) {
                case CardRankFour:
                    return 0.57;
                case CardRankThree:
                    if (firstCard.suit == secondCard.suit)
                        return 0.38;
                    else
                        return 0.344;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.363;
                    else
                        return 0.325;
                default:
                    return 0;
            }
        case CardRankThree:
            switch (secondCard.rank) {
                case CardRankThree:
                    return 0.537;
                case CardRankTwo:
                    if (firstCard.suit == secondCard.suit)
                        return 0.351;
                    else
                        return 0.312;
                default:
                    return 0;
            }
        case CardRankTwo:
            switch (secondCard.rank) {
                case CardRankTwo:
                    return 0.503;
                default:
                    return 0;
            }
        default:
            return 0;
    }
    
}

- (void)gameEndedWithResult:(BOOL)win balance:(NSInteger)money{
    
    self.moneyLeft += money;
    
    if (!win){
        HandStrength *playerHand = [self evaluateHand:self.gameState.playerHand];
        HandStrength *botHand = [self evaluateHand:self.gameState.botHand];
        if ([playerHand compareTo:botHand] < 0){
            self.aggression += (1 - self.aggression) / 5.0f;
        }else{
            self.aggression -= (1 - self.aggression) / 5.0f;
        }
    }
}

@end
