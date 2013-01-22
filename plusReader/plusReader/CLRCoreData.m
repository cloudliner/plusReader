//
//  CLRCoreData.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/17.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRCoreData.h"

@implementation CLRCoreData

@synthesize context = _context;
@synthesize model = _model;
@synthesize coordinator = _coordinator;

- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(CLREntityEnumerations)entity fetchRequest:(NSFetchRequest *)fetchRequest {
  NSEntityDescription *entityDescription = [self entityForEnumerations:entity];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setFetchBatchSize:20];

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
  
  return fetchedResultsController;
}

- (id)insertNewObjectForEntity:(CLREntityEnumerations)entity {
  NSString *entityName = [self entityNameForEnumerations:entity];
  id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
  return object;
}

- (void)deleteForEntity:(CLREntityEnumerations)entity timestamp:(NSTimeInterval)timestamp {
  NSEntityDescription *entityDescription = [self entityForEnumerations:entity];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setFetchBatchSize:20];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"update" ascending:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  NSPredicate *predidate = [NSPredicate predicateWithFormat:@"update != %@", [NSDate dateWithTimeIntervalSinceReferenceDate:timestamp]];
  
  [fetchRequest setPredicate:predidate];
  
  NSFetchedResultsController *fetchedResultsController
  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.context
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
  
  NSError *error = nil;
  if (![fetchedResultsController performFetch:&error]) {
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    CLRGAITrackException(error);
    abort();
  }
  
  NSArray *arrayToDelete = [fetchedResultsController fetchedObjects];
  for (NSManagedObject *object in arrayToDelete) {
    [self.context deleteObject:object];
  }
}

- (NSArray *)arrayForEntity:(CLREntityEnumerations)entity predicate:(NSPredicate *)predicate {
  NSEntityDescription *entityDescription = [self entityForEnumerations:entity];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setFetchBatchSize:20];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"update" ascending:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  if (predicate != nil) {
    [fetchRequest setPredicate:predicate];
  }
  
  NSFetchedResultsController *fetchedResultsController
  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.context
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
  
  NSError *error = nil;
  if (![fetchedResultsController performFetch:&error]) {
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    CLRGAITrackException(error);
    abort();
  }
  
  NSArray *array = [fetchedResultsController fetchedObjects];
  return array;
}

- (NSString *)entityNameForEnumerations:(CLREntityEnumerations)enumerations {
  switch (enumerations) {
    case CLREntityItem:
      return @"Item";
    case CLREntityOrdering:
      return @"Ordering";
    case CLREntityItemCursor:
      return @"ItemCursor";
    case CLREntityStreamCursor:
      return @"StreamCursor";
    case CLREntityFeed:
      return @"Feed";
    case CLREntityTag:
      return @"Tag";
    default:
      return nil;
  }
}

- (NSEntityDescription *)entityForEnumerations:(CLREntityEnumerations)enumerations {
  NSString *entityName = [self entityNameForEnumerations:enumerations];
  if (entityName != nil) {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    return entity;
  } else {
    return nil;
  }
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.context;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
      CLRGAITrackException(error);
      abort();
    }
  }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)context {
  if (_context != nil) {
    return _context;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self coordinator];
  if (coordinator != nil) {
    _context = [[NSManagedObjectContext alloc] init];
    [_context setPersistentStoreCoordinator:coordinator];
  }
  return _context;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)model {
  if (_model != nil) {
    return _model;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"plusReader" withExtension:@"momd"];
  _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _model;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)coordinator {
  if (_coordinator != nil) {
    return _coordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"plusReader.sqlite"];
  
  NSError *error = nil;
  _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
  if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    
    if (error.code == 134100) {
      // TODO: データ型が合わなかった場合にはとりあえず削除（マイグレーションについては後で検討）
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      // * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
      // @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
      
      // データストアを再作成
      _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
      if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        CLRGAITrackException(error);
        abort();
      }
    } else {
      CLRGAITrackException(error);
      abort();
    }
  }
  
  return _coordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
