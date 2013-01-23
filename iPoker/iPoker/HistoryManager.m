//
//  HistoryManager.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/17/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "HistoryManager.h"
#import <CoreData/CoreData.h>

@interface HistoryManager ()



@end

@implementation HistoryManager

HistoryManager *manager;
NSManagedObjectContext * __managedObjectContext;
NSManagedObjectModel * __managedObjectModel;
NSPersistentStoreCoordinator * __persistentStoreCoordinator;

+ (HistoryManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"iPoker.sqlite"]];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

- (NSString*)applicationDocumentsDirectory {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentDirectory;
}

#pragma mark - Actual work

- (void)addPlayerDecisionWithRanking:(HandRanking)ranking highCard:(CardRank)highCard andStrategy:(Strategy) strategy forRound:(Round)round{
    PlayerDecision *playerDesicion = [[PlayerDecision alloc] initWithEntity:[NSEntityDescription entityForName:@"PlayerDecision" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    playerDesicion.ranking = @(ranking);
    playerDesicion.highCard = @(highCard);
    playerDesicion.strategy = @(strategy);
    playerDesicion.round = @(round);
    [self.managedObjectContext save:nil] ;
}

- (void)addPlayerHoleDecisionWithFirstCard:(CardRank)firstCardRank secondCard:(CardRank)secondCardRank suited:(BOOL)suited andStrategy:(Strategy)strategy{
    PlayerHoleDecision *playerHoleDecision = [[PlayerHoleDecision alloc] initWithEntity:[NSEntityDescription entityForName:@"PlayerHoleDecision" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    playerHoleDecision.firstCard = @(firstCardRank);
    playerHoleDecision.secondCard = @(secondCardRank);
    playerHoleDecision.suited = @(suited);
    playerHoleDecision.strategy = @(strategy);
    [self.managedObjectContext save:nil];
}

- (NSArray *) fetchPlayerHoleDecisions{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerHoleDecision" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return result;
}

- (NSArray *) fetchPlayerDecisionsForRound: (Round) round{
    
    if (round == RoundBettingRound){
        return [self fetchPlayerHoleDecisions];
    }else{
        NSArray *result = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerDecision" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"round == %d", round];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        
        result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        return result;
    }
    
  
    
}

@end
