//
//  CLRCoreData.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/17.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLREntityEnumerations) {
  CLREntityNone = 0,
  CLREntityItem,
  CLREntityOrdering,
  CLREntityItemCursor,
  CLREntityStreamCursor,
  CLREntityFeed,
  CLREntityTag,
};

@interface CLRCoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (readonly, strong, nonatomic) NSManagedObjectModel *model;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *coordinator;

- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(CLREntityEnumerations)entity fetchRequest:(NSFetchRequest *)fetchRequest;
- (id)insertNewObjectForEntity:(CLREntityEnumerations)entity;
- (void)deleteForEntity:(CLREntityEnumerations)entity timestamp:(NSTimeInterval)timestamp;
- (NSArray *)arrayForEntity:(CLREntityEnumerations)entity predicate:(NSPredicate *)predicate;
- (void)saveContext;
@end
