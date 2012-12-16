//
//  Player.m
//  iPoker
//
//  Created by Georgi Bachvarov on 12/15/12.
//  Copyright (c) 2012 Georgi Bachvarov. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithGameState:(GameState *)state{
    self = [self init];
    if (self){
        self.gameState = state;
    }
    return self;
}

- (NSArray *)availableCards{
    return  nil;
}

- (PlayerAction *)nextAction{
    return nil;
}

- (HandStrength *) evaluateHand{
    
    NSArray *hand = [self availableCards];
    
    //read hand
    int numberOfCardsInSuit[4];
    int numberOfCardsOfRank[13];
    bool card_exists[4][13];
    
    for (Card *card in hand) {
        numberOfCardsInSuit[card.suit] ++;
        numberOfCardsOfRank[card.rank] ++;
        card_exists[card.suit][card.rank] = true;
    }
    
    //analyze hand
    
    int flushStrength;
    int flushSuit;
    int straightStrength;
    int fourStrength;
    int threeStrength;
    int pairStrength;
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
        }
    }
    
    return handStrength;


    
}

@end
