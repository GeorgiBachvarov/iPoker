//
//  StrategyAnalyzer.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/18/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "StrategyAnalyzer.h"

#import "GameState.h"

@implementation StrategyAnalyzer

+ (NSDictionary *) strategiesForRounds: (NSDictionary *) playerActions basedOnCards:(NSArray *)cards{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if ([playerActions objectForKey:@(RoundBettingRound)] && [[playerActions objectForKey:@(RoundBettingRound)] count] > 0){
        CGFloat winChance = [self initialWinCoefficientForHand:[cards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]];
        
        Action bettingRoundAction = [[[playerActions objectForKey:@(RoundBettingRound)] objectAtIndex:0] integerValue];
        
        if (winChance >= 5.5){
            if (bettingRoundAction == ActionRaise) {
                [result setObject:@(StrategyValueBet) forKey:@(RoundBettingRound)];
            }else{
                [result setObject:@(StrategySlowPlay) forKey:@(RoundBettingRound)];
            }
        }
        
        if (winChance >=4 && winChance < 5.5){
            if (bettingRoundAction == ActionCall){
                [result setObject:@(StrategyValueBet) forKey:@(RoundBettingRound)];
            }else{
                [result setObject:@(StrategyBluff) forKey:@(RoundBettingRound)];
            }
        }
        
        if (winChance < 4){
            [result setObject:@(StrategyBluff) forKey:@(RoundBettingRound)];
        }
    }
    
    NSArray *flopActions = [playerActions objectForKey:@(RoundTheFlop)];
    
    if (flopActions.count > 0){
        NSArray *flopHand = [cards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
        HandStrength *flopHandStrength = [self evaluateHand:flopHand];
        
        if (flopHandStrength.handRanking >= HandRankingOnePair){
            if ([[flopActions objectAtIndex:0] integerValue] == ActionRaise){
                [result setObject:@(StrategyValueBet) forKey:@(RoundTheFlop)];
            }else{
                [result setObject:@(StrategySlowPlay) forKey:@(RoundTheFlop)];
            }
        }else{
            [result setObject:@(StrategyBluff) forKey:@(RoundTheFlop)];
        }
    }
    
    NSArray *turnActions = [playerActions objectForKey:@(RoundTheTurn)];
    
    if (turnActions.count > 0){
        NSArray *turnHand = [cards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)]];
        HandStrength *turnHandStrength = [self evaluateHand:turnHand];
        
        if (turnHandStrength.handRanking >= HandRankingTwoPair){
            if ([[turnActions objectAtIndex:0] integerValue] == ActionRaise){
                [result setObject:@(StrategyValueBet) forKey:@(RoundTheTurn)];
            }else{
                [result setObject:@(StrategySlowPlay) forKey:@(RoundTheTurn)];
            }
        }else if (turnHandStrength.handRanking == HandRankingOnePair){
            if ([[turnActions objectAtIndex:0] integerValue] == ActionRaise){
                [result setObject:@(StrategyBluff) forKey:@(RoundTheTurn)];
            }else{
                [result setObject:@(StrategyValueBet) forKey:@(RoundTheTurn)];
            }
        }else{
            if ([[turnActions lastObject] integerValue] == ActionRaise){
                [result setObject:@(StrategyBluff) forKey:@(RoundTheTurn)];
            }
        }
    }
    
   
    
    NSArray *riverActions = [playerActions objectForKey:@(RoundTheRiver)];
    
    if (riverActions.count > 0){
        NSArray *riverHand = [cards objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 7)]];
        HandStrength *riverHandStrength = [self evaluateHand:riverHand];
        
        if (riverHandStrength.handRanking >= HandRankingThreeOfAKind){
            if ([[riverActions objectAtIndex:0] integerValue] == ActionRaise){
                [result setObject:@(StrategyValueBet) forKey:@(RoundTheRiver)];
            }else{
                [result setObject:@(StrategySlowPlay) forKey:@(RoundTheRiver)];
            }
        }else if (riverHandStrength.handRanking == HandRankingTwoPair){
            [result setObject:@(StrategyValueBet) forKey:@(RoundTheRiver)];
            
        }else{
            if ([[turnActions objectAtIndex:0] integerValue] == ActionRaise){
                [result setObject:@(StrategyBluff) forKey:@(RoundTheRiver)];
            }
        }
    }
    
  
    
    return result;
}

+ (CGFloat) initialWinCoefficientForHand: (NSArray *)cards{
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

+ (HandStrength *) evaluateHand: (NSArray *) hand{
    
    //read hand
    int numberOfCardsInSuit[4];
    int numberOfCardsOfRank[13];
    bool card_exists[4][13];
    
    for (int i = 0; i < 4; i++){
        numberOfCardsInSuit[i] = 0;
    }
    for (int i = 0; i < 13; i++){
        numberOfCardsOfRank[i] = 0;
    }
    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 13; j++){
            card_exists[i][j] = false;
        }
    }
    
    for (Card *card in hand) {
        numberOfCardsInSuit[card.suit] ++;
        numberOfCardsOfRank[card.rank] ++;
        card_exists[card.suit][card.rank] = true;
    }
    
    //analyze hand
    
    int flushStrength = 0;
    int flushSuit = 0;
    int straightStrength = 0;
    int fourStrength = 0;
    int threeStrength = 0;
    int pairStrength = 0;
    int numberOfPairs = 0;
    
    //check for flush
    for (int suit = 0; suit<4; suit++) {
        if (numberOfCardsInSuit[suit] == 5){
            for (int card = 12; card >= 0; card --){
                if (card_exists[suit][card]){
                    flushStrength = card;
                    break;
                }
            }
            flushSuit = suit;
            break;
        }
    }
    
    //check for straight
    uint consecutive = 0;
    uint rank = 0;
    while (rank < 13) {
        if (consecutive >= 5){
            straightStrength = rank;
        }
        if (numberOfCardsOfRank[rank]){
            consecutive++;
        }else{
            consecutive = 0;
        }
        rank++;
    }
    
    //check for four, three or pairs
    for (int rank = 0; rank < 13; rank++) {
        if (numberOfCardsOfRank[rank]==4){
            fourStrength = rank;
        }
        if (numberOfCardsOfRank[rank]==3){
            threeStrength = rank;
        }
        if (numberOfCardsOfRank[rank]==2){
            pairStrength = rank;
            numberOfPairs++;
        }
    }
    
    
    //form result
    HandStrength *handStrength = [[HandStrength alloc] init];
    
    
    // straight/royal flush?
    if(flushStrength && straightStrength){
        int consecutive = 0;
        int straightFlushStrength = 0;
        for (int rank = 0; rank<13; rank++){
            if (consecutive >=5){
                straightFlushStrength = rank;
            }
            if (card_exists[flushSuit][rank]){
                consecutive ++;
            }else{
                consecutive = 0;
            }
        }
        
        if (straightFlushStrength == 12){
            handStrength.handRanking = HandRankingRoyalFlush;
            handStrength.highCard = CardRankAce;
            return handStrength;
        }
        if (straightFlushStrength){
            handStrength.handRanking = HandRankingStraightFlush;
            handStrength.highCard = straightFlushStrength;
            return handStrength;
        }
    }
    
    // four of a kind?
    if (fourStrength){
        handStrength.handRanking = HandRankingFourOfAKind;
        handStrength.highCard = fourStrength;
        return handStrength;
    }
    
    // full house?
    if (threeStrength && pairStrength){
        handStrength.handRanking = HandRankingFullHouse;
        handStrength.highCard = threeStrength;
        return handStrength;
    }
    
    
    // flush?
    if (flushStrength){
        handStrength.handRanking = HandRankingFlush;
        handStrength.highCard = flushStrength;
        return handStrength;
    }
    
    // straight?
    if (straightStrength){
        handStrength.handRanking = HandRankingStraight;
        handStrength.highCard = straightStrength;
        return handStrength;
    }
    
    // three of a kind?
    if (threeStrength){
        handStrength.handRanking = HandRankingThreeOfAKind;
        handStrength.highCard = threeStrength;
        return handStrength;
    }
    
    // pair?
    if (pairStrength){
        if (numberOfPairs >= 2){
            handStrength.handRanking = HandRankingTwoPair;
        }else{
            handStrength.handRanking = HandRankingOnePair;
        }
        handStrength.highCard = pairStrength;
        return handStrength;
    }
    
    
    handStrength.handRanking = HandRankingNone;
    
    for (int rank = 12; rank >=0 ; rank--){
        if (numberOfCardsOfRank[rank]){
            handStrength.highCard = rank;
            break;
        }
    }
    
    return handStrength; 
}

@end

