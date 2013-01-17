//
//  CLRCoreData.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/17.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRCoreData.h"

@implementation CLRCoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSFetchedResultsController *)copyFetchedResultsControllerWithEntity:(CLREntityEnumerations)entity fetchRequest:(NSFetchRequest *)fetchRequest {
  NSEntityDescription *entityDescription = [self entityForEnumerations:entity];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setFetchBatchSize:20];

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
  
  return fetchedResultsController;
}

- (id)insertNewObjectForEntity:(CLREntityEnumerations)entity {
  NSString *entityName = [self entityNameForEnumerations:entity];
  id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
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
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
  
  NSError *error = nil;
  if (![fetchedResultsController performFetch:&error]) {
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  NSArray *arrayToDelete = [fetchedResultsController fetchedObjects];
  for (NSManagedObject *object in arrayToDelete) {
    [self.managedObjectContext deleteObject:object];
  }
}

// TODO: このメソッドは問題ありかも？
- (NSArray *)copyResultForEntity:(CLREntityEnumerations)entity predicate:(NSPredicate *)predicate {
  NSEntityDescription *entityDescription = [self entityForEnumerations:entity];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setFetchBatchSize:20];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"update" ascending:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  [fetchRequest setPredicate:predicate];
  
  NSFetchedResultsController *fetchedResultsController
  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
  
  NSError *error = nil;
  if (![fetchedResultsController performFetch:&error]) {
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  NSArray *array = [fetchedResultsController fetchedObjects];
  return array;
}

- (NSString *)entityNameForEnumerations:(CLREntityEnumerations)enumerations {
  switch (enumerations) {
    case CLREntityItem: {
      return @"Item";
    }
    case CLREntityOrdering: {
      return @"Ordering";
    }
    case CLREntityItemCursor: {
      return @"ItemCursor";
    }
    case CLREntityStreamCursor: {
      return @"StreamCursor";
    }
    case CLREntityFeed: {
      return @"Feed";
    }
    case CLREntityTag: {
      return @"Tag";
    }
    default: {
      return nil;
    }
  }
}
- (NSEntityDescription *)entityForEnumerations:(CLREntityEnumerations)enumerations {
  NSString *entityName = [self entityNameForEnumerations:enumerations];
  if (entityName != nil) {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return entity;
  } else {
    return nil;
  }
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"plusReader" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"plusReader.sqlite"];
  
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    
    if (error.code == 134100) {
      // TODO: データ型が合わなかった場合にはとりあえず削除（マイグレーションについては後で検討）
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      // * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
      // @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
      
      // データストアを再作成
      _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
      if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
      }
    } else {
      abort();
    }
  }
  
  return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
