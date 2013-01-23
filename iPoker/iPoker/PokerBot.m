//
//  PokerBot.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "PokerBot.h"

#import "HistoryManager.h"

@interface PokerBot (){

}

@property (nonatomic, assign) CGFloat aggression;
@property (nonatomic, assign) Strategy lastAssumedPlayerStrategy;

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

- (void)nextAction{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self calculateNextAction];
    });
}

- (void) calculateNextAction{
    PlayerAction *botAction = [[PlayerAction alloc] init];
    
    //posting blinds
    if (self.gameState.round == RoundPostingBlinds){
        if (!self.gameState.playerIsDealer){
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
        
        CGFloat objectiveWinCoefficient = [StrategyAnalyzer initialWinCoefficientForHand:self.gameState.botHand];
        Strategy probablePlayerStrategy = [self calculateStrategyBasedOnHistory];
        
        if (probablePlayerStrategy != StrategyUndefined){
            self.lastAssumedPlayerStrategy = probablePlayerStrategy;
        }

        if (((objectiveWinCoefficient + self.aggression > 1) || probablePlayerStrategy == StrategyBluff ) && self.gameState.currentRaise != self.gameState.options.moneyLimit){

            botAction.action = ActionRaise;
            
            NSUInteger overCurrentRaise = 2*(uint)(self.aggression * (float)self.gameState.currentRaise);
            
            if (probablePlayerStrategy == StrategySlowPlay){
                overCurrentRaise = overCurrentRaise/4;
            }
            if (probablePlayerStrategy == StrategyValueBet){
                overCurrentRaise = overCurrentRaise/2;
            }
            NSUInteger amountToRaise = self.gameState.currentRaise + overCurrentRaise;
            
            if (amountToRaise > self.moneyLeft){
                amountToRaise = self.moneyLeft;
            }
            
            if (amountToRaise > self.gameState.options.moneyLimit){
                amountToRaise = self.gameState.options.moneyLimit;
            }
            
            
            
            botAction.amount = amountToRaise;
            
            
        }else if ((objectiveWinCoefficient + self.aggression > 0.85 ) || probablePlayerStrategy == StrategyBluff){
            botAction.action = ActionCall;
            botAction.amount = self.gameState.currentRaise;
        }else{
            botAction.action = ActionFold;
            botAction.amount = self.gameState.currentPot;
        }
        
    }
    
    //any of the other three rounds Flop/Turn/River
    if (self.gameState.round > RoundBettingRound){

        HandStrength *handStrength = [StrategyAnalyzer evaluateHand: [self availableCards]];
        
        CGFloat handStrengthCoefficient1 = [self runSimulation];
        CGFloat handStrengthCoefficient2 = [self handStrengthCoefficient:[StrategyAnalyzer evaluateHand:[self.gameState.botHand arrayByAddingObjectsFromArray:self.gameState.communityCards]] forRound:self.gameState.round];
        NSLog(@"bot has %d , %d high", handStrength.handRanking, handStrength.highCard);
        NSLog(@"result of simulation: %f", handStrengthCoefficient1);
        NSLog(@"result of analysis %f", handStrengthCoefficient2);
        
        CGFloat handStrengthCoefficient = (handStrengthCoefficient1 + handStrengthCoefficient2) / 2;
        
        NSLog(@"combined result: %f", handStrengthCoefficient);
        
        Strategy probablePlayerStrategy = [self calculateStrategyBasedOnHistory];
        if (probablePlayerStrategy != StrategyUndefined){
            self.lastAssumedPlayerStrategy = probablePlayerStrategy;
        }
        
        CGFloat playerAverageHandStrengthCoefficient = 0;
        NSUInteger numberOfHandsPlayedWithThisStrategy = 0;
        for (PlayerDecision *playerDecision in [[HistoryManager sharedInstance]
             fetchPlayerDecisionsForRound:self.gameState.round]) {
            if ([playerDecision.strategy integerValue] == probablePlayerStrategy){
                numberOfHandsPlayedWithThisStrategy ++;
                HandStrength *handStrength = [[HandStrength alloc] init];
                handStrength.handRanking = [playerDecision.ranking integerValue];
                handStrength.highCard = [playerDecision.highCard integerValue];
                playerAverageHandStrengthCoefficient += [self handStrengthCoefficient:handStrength forRound:self.gameState.round];
            }
        }
        
        playerAverageHandStrengthCoefficient = playerAverageHandStrengthCoefficient / numberOfHandsPlayedWithThisStrategy;
            
        if ((handStrengthCoefficient + self.aggression > 1 || probablePlayerStrategy == StrategyBluff) && self.gameState.currentRaise != self.gameState.options.moneyLimit && probablePlayerStrategy != StrategySlowPlay){
            
            botAction.action = ActionRaise;
            
            NSUInteger overCurrentRaise = 2*(uint)(self.aggression * (float)self.gameState.currentRaise);
            NSUInteger amountToRaise = self.gameState.currentRaise + overCurrentRaise;
            
            if (probablePlayerStrategy == StrategyValueBet){
                overCurrentRaise = overCurrentRaise / 2;
            }
            if (probablePlayerStrategy == StrategySlowPlay){
                overCurrentRaise = overCurrentRaise / 3;
            }
            
            if (amountToRaise > self.moneyLeft){
                amountToRaise = self.moneyLeft;
            }
            
            if (amountToRaise > self.gameState.options.moneyLimit){
                amountToRaise = self.gameState.options.moneyLimit;
            }
            
            botAction.amount = amountToRaise;
            
            
        }else if ((handStrengthCoefficient + self.aggression > 0.85 && fabsf(handStrengthCoefficient - playerAverageHandStrengthCoefficient < 0.2))|| self.gameState.currentPot == self.gameState.currentRaise){
            botAction.action = ActionCall;
            botAction.amount = self.gameState.currentRaise;
        }else{
            botAction.action = ActionFold;
            botAction.amount = self.gameState.currentPot;
        }
        
    }
    
    if (botAction.amount >= self.moneyLeft){
        botAction.action = ActionAllIn;
        botAction.amount = self.moneyLeft;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate botChoseAction:botAction];
    });
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

- (CGFloat) potWinCoefficient{
    if (self.gameState.currentPot != self.gameState.currentRaise){
        return (float)self.gameState.currentPot / (float) (self.gameState.currentRaise - self.gameState.currentPot);
    }else{
        return CGFLOAT_MAX;
    }
}

- (CGFloat) runSimulation{
    
    CGFloat successes = 0;
    NSInteger numberOfSimulations = 10000;
    
    for (int simulationNumber = 0; simulationNumber < numberOfSimulations; simulationNumber++) {
        NSMutableArray *deck = [NSMutableArray arrayWithArray:self.gameState.deck];
        NSUInteger randomNumber = arc4random() % deck.count;
        Card *randomPlayerCard1 = [deck objectAtIndex:randomNumber];
        [deck removeObjectAtIndex:randomNumber];
        randomNumber = arc4random() % deck.count;
        Card *randomPlayerCard2 = [deck objectAtIndex:randomNumber];
        [deck removeObjectAtIndex:randomNumber];
        NSArray *playerHand = [NSArray arrayWithObjects:randomPlayerCard1, randomPlayerCard2, nil];
        randomNumber = arc4random() % deck.count;
        Card *randomCommunityCard = [deck objectAtIndex:randomNumber];
        [deck removeObjectAtIndex:randomNumber];
        
        NSArray *botCards = [[self.gameState.communityCards arrayByAddingObjectsFromArray:self.gameState.botHand] arrayByAddingObject:randomCommunityCard];
        NSArray *playerCards = [[self.gameState.communityCards arrayByAddingObjectsFromArray:playerHand] arrayByAddingObject:randomCommunityCard];
        
        NSInteger gameWon = [[StrategyAnalyzer evaluateHand:botCards] compareTo:[StrategyAnalyzer evaluateHand:playerCards]];
        if (gameWon == 1){
            successes++;
        }else if (gameWon == 0){
            successes += 0.5f;
        }
    }
    
    return (CGFloat) successes / (CGFloat) numberOfSimulations;
}

- (Strategy) calculateStrategyBasedOnHistory{
    
    switch (self.gameState.round) {
        case RoundBettingRound:{
            NSArray *holeDecisions = [[HistoryManager sharedInstance] fetchPlayerHoleDecisions];
            
            CGFloat bluffPercentage = 0;
            CGFloat valueBetPercentage = 0;
            CGFloat slowPlayPercentage = 0;
            for (PlayerHoleDecision *holeDecision in holeDecisions) {
                if ([holeDecision.strategy integerValue] == StrategyBluff){
                    bluffPercentage ++;
                }
                if ([holeDecision.strategy integerValue] == StrategySlowPlay){
                    slowPlayPercentage ++;
                }
                if ([holeDecision.strategy integerValue] == StrategyValueBet){
                    valueBetPercentage ++;
                }
            }
            bluffPercentage  = bluffPercentage / holeDecisions.count;
            valueBetPercentage = bluffPercentage / holeDecisions.count;
            slowPlayPercentage = slowPlayPercentage / holeDecisions.count;
            
            
            NSArray *actionsSoFar = [self.gameState.playerActionsByRound objectForKey:@(RoundBettingRound)];
            
            
            if (actionsSoFar.count != 0){
                Action lastAction = [[actionsSoFar lastObject] integerValue];
                if (lastAction == ActionRaise){
                    if (bluffPercentage >= 0.4){
                        return StrategyBluff;
                    }else{
                        return StrategyValueBet;
                    }
                }else{
                    //action is call
                    if (slowPlayPercentage > 0.2){
                        return StrategySlowPlay;
                    }else{
                        return StrategyValueBet;
                    }
                }
            }else{
                if (bluffPercentage >= 0.4){
                    return StrategyBluff;
                }
                if (valueBetPercentage >= 0.2){
                    return StrategyValueBet;
                }
                if (slowPlayPercentage >= 0.4){
                    return StrategySlowPlay;
                }
            }
            
            return StrategyUndefined;
        }
            break;
            
        case RoundTheFlop:{
            NSArray *flopDecisions = [[HistoryManager sharedInstance] fetchPlayerDecisionsForRound:RoundTheFlop];
            
            CGFloat bluffPercentage = 0;
            CGFloat valueBetPercentage = 0;
            CGFloat slowPlayPercentage = 0;
            for (PlayerDecision *playerFlopDecision in flopDecisions) {
                if ([playerFlopDecision.strategy integerValue] == StrategyBluff){
                    bluffPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategySlowPlay){
                    slowPlayPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategyValueBet){
                    valueBetPercentage ++;
                }
            }
            bluffPercentage  = bluffPercentage / flopDecisions.count;
            valueBetPercentage = bluffPercentage / flopDecisions.count;
            slowPlayPercentage = slowPlayPercentage / flopDecisions.count;
            
            NSArray *flopActionsSoFar = [self.gameState.playerActionsByRound objectForKey:@(RoundTheFlop)];
            
            if (flopActionsSoFar.count != 0){
                if ([[flopActionsSoFar lastObject] integerValue] == ActionRaise){
                    if ([[flopActionsSoFar objectAtIndex:0] integerValue] == ActionCall){
                        if (bluffPercentage >= 0.5){
                            return StrategyBluff;
                        }else{
                            return StrategySlowPlay;
                        }
                    }
                }else{
                    //call
                    if (slowPlayPercentage >= 0.2){
                        return StrategySlowPlay;
                    }
                    return StrategyValueBet;
                }
            }else{
                return StrategyUndefined;
            }
        }
            break;
        case RoundTheTurn:{
            NSArray *turnDecisions = [[HistoryManager sharedInstance] fetchPlayerDecisionsForRound:RoundTheFlop];
            
            CGFloat bluffPercentage = 0;
            CGFloat valueBetPercentage = 0;
            CGFloat slowPlayPercentage = 0;
            for (PlayerDecision *playerFlopDecision in turnDecisions) {
                if ([playerFlopDecision.strategy integerValue] == StrategyBluff){
                    bluffPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategySlowPlay){
                    slowPlayPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategyValueBet){
                    valueBetPercentage ++;
                }
            }
            bluffPercentage  = bluffPercentage / turnDecisions.count;
            valueBetPercentage = bluffPercentage / turnDecisions.count;
            slowPlayPercentage = slowPlayPercentage / turnDecisions.count;
            
            
            NSArray *turnActionsSoFar = [self.gameState.playerActionsByRound objectForKey:@(RoundTheTurn)];
            if (turnActionsSoFar.count > 0){
                if ([[turnActionsSoFar lastObject] integerValue] == ActionRaise){
                    if (self.lastAssumedPlayerStrategy == StrategySlowPlay){
                        return StrategyValueBet;
                    }
                    if (bluffPercentage >= 0.4){
                        return StrategyBluff;
                    }
                }else{
                    if (slowPlayPercentage >= 0.2){
                        return StrategySlowPlay;
                    }
                    return StrategyValueBet;
                }
            }
        }
            break;
        case RoundTheRiver:{
            NSArray *riverDecisions = [[HistoryManager sharedInstance] fetchPlayerDecisionsForRound:RoundTheFlop];
            
            CGFloat bluffPercentage = 0;
            CGFloat valueBetPercentage = 0;
            CGFloat slowPlayPercentage = 0;
            for (PlayerDecision *playerFlopDecision in riverDecisions) {
                if ([playerFlopDecision.strategy integerValue] == StrategyBluff){
                    bluffPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategySlowPlay){
                    slowPlayPercentage ++;
                }
                if ([playerFlopDecision.strategy integerValue] == StrategyValueBet){
                    valueBetPercentage ++;
                }
            }
            bluffPercentage  = bluffPercentage / riverDecisions.count;
            valueBetPercentage = bluffPercentage / riverDecisions.count;
            slowPlayPercentage = slowPlayPercentage / riverDecisions.count;
            
            NSArray *riverActionsSoFar = [self.gameState.playerActionsByRound objectForKey:@(RoundTheRiver)];
            
            if (riverActionsSoFar.count > 0){
                if ([[riverActionsSoFar lastObject] integerValue] == ActionRaise){
                    if (self.lastAssumedPlayerStrategy == StrategySlowPlay){
                        return StrategyValueBet;
                    }
                    if (bluffPercentage >= 0.4){
                        return StrategyBluff;
                    }
                }else{
                    return StrategyValueBet;
                }
            }else{
                if (slowPlayPercentage >= 0.2){
                    return StrategySlowPlay;
                }
                return StrategyValueBet;
            }
        }
            break;
        default:
            break;
    }
    
    return StrategyUndefined;
  
}



- (void)gameEndedWithResult:(NSInteger)winner playerStrategy:(NSDictionary *)strategy{
    
    if (winner >= 0){
        HandStrength *playerHand = [StrategyAnalyzer evaluateHand:self.gameState.playerHand];
        HandStrength *botHand = [StrategyAnalyzer evaluateHand:self.gameState.botHand];
        if ([playerHand compareTo:botHand] < 0){
            self.aggression += (1 - self.aggression) / 5.0f;
        }else{
            self.aggression -= (1 - self.aggression) / 5.0f;
        }
        NSLog(@"Bot Aggression: %f", self.aggression);
    }
    
    
    NSLog(@"Logging result in history..");
    NSArray *playerHand = self.gameState.playerHand;
    [[HistoryManager sharedInstance] addPlayerHoleDecisionWithFirstCard:[[playerHand objectAtIndex:0] rank] secondCard:[[playerHand objectAtIndex:1] rank] suited:[[playerHand objectAtIndex:0] suit] == [[playerHand objectAtIndex:1] suit] andStrategy:[[strategy objectForKey:@(RoundBettingRound)] integerValue]];
    
    
     HandStrength *flopStrength = [StrategyAnalyzer evaluateHand:[playerHand arrayByAddingObjectsFromArray:[self.gameState.communityCards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]]]];
    [[HistoryManager sharedInstance] addPlayerDecisionWithRanking:flopStrength.handRanking  highCard:flopStrength.highCard andStrategy:[[strategy objectForKey:@(RoundTheFlop)] integerValue] forRound:RoundTheFlop];
    
     HandStrength *turnStrength = [StrategyAnalyzer evaluateHand:[playerHand arrayByAddingObjectsFromArray:[self.gameState.communityCards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]]]];
    [[HistoryManager sharedInstance] addPlayerDecisionWithRanking:turnStrength.handRanking  highCard:turnStrength.highCard andStrategy:[[strategy objectForKey:@(RoundTheTurn)] integerValue] forRound:RoundTheTurn];
    
    HandStrength *riverStrength = [StrategyAnalyzer evaluateHand:[playerHand arrayByAddingObjectsFromArray:[self.gameState.communityCards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]]]];
    [[HistoryManager sharedInstance] addPlayerDecisionWithRanking:riverStrength.handRanking  highCard:riverStrength.highCard andStrategy:[[strategy objectForKey:@(RoundTheRiver)] integerValue] forRound:RoundTheRiver];
    
}



@end
