//
//  CLRAppDelegate.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRAppDelegate.h"

#import "CLRStreamViewController.h"
#import "CLRGoogleOAuth.h"
#import "CLRCoreData.h"

@implementation CLRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // TODO: とりあえずiPhoneに限定
  /*
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
      
    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    CLMasterViewController *controller = (CLMasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
  } else {
  */
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    CLRStreamViewController *controller = (CLRStreamViewController *)navigationController.topViewController;
    controller.coreData = [[CLRCoreData alloc] init];
  /*
  }
  */
  
  // GAI
  CLRGAIInit();
  
  // Google OAuthの初期化
  _googleOAuthClient = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:@"https://accounts.google.com/"]
                                          clientID:GOOGLE_OAUTH2_CLIENT_ID
                                            secret:GOOGLE_OAUTH2_CLIENT_SECRET];
  
  // 保存済みの認証情報を取得
  AFOAuthCredential *storedCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
  if (storedCredential != nil && storedCredential.isExpired) {
    [_googleOAuthClient setAuthorizationHeaderWithCredential:storedCredential];
    
    // TODO: 起動時にネットワークがつながらない場合を考慮する必要あり
    // 認証をリフレッシュ
    [_googleOAuthClient authenticateUsingOAuthWithPath:@"https://accounts.google.com/o/oauth2/token"
                              refreshToken:storedCredential.refreshToken
                                   success:^(AFOAuthCredential *credential) {
                                     CLRLog(@"success:%@", credential.description);
                                     
                                     // 認証データを保存
                                     [AFOAuthCredential storeCredential:credential
                                                         withIdentifier:GOOGLE_OAUTH2_STORE_NAME];
                                     
                                   } failure:^(NSError *error) {
                                     CLRLog(@"failure:%@", error.description);
                                     
                                   }];
  }
  
  // バージョン表示
  NSString *versionNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  CLRLog(@"Version:%@, Build:%@", versionNum, buildNum);
  
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

@end
