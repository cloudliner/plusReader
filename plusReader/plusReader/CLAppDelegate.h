//
//  CLAppDelegate.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) id<GAITracker> tracker;

// TODO: データの持ち方
@property (nonatomic, retain) NSString *access_token;
@property (nonatomic, retain) NSString *expires_in;
@property (nonatomic, retain) NSString *refresh_token;
@property (nonatomic, retain) NSString *token_type;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
