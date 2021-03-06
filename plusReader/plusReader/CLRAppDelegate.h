//
//  CLRAppDelegate.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLRCoreData;
@class CLRGRRetrieve;

@interface CLRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AFOAuth2Client *googleOAuthClient;
@property (strong, nonatomic) CLRCoreData *coreData;
@property (strong, nonatomic) CLRGRRetrieve *grRetrieve;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
