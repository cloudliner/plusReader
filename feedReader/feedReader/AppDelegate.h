//
//  AppDelegate.h
//  feedReader
//
//  Created by 大野 廉 on 2012/12/15.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *password;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
// - (void)load;

@end
