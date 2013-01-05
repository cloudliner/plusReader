//
//  CLGRRetrieve.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/05.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CLGRRetrieveSuccessBlock)(NSDictionary* JSON);

@interface CLGRRetrieve : NSObject

@property (strong, nonatomic) AFHTTPClient *httpClient;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) AFOAuthCredential *credential;

-(void)listTag:(CLGRRetrieveSuccessBlock)successBlock;
-(void)listSubscription;
-(void)listPreference;
-(void)listStreamPreference;
-(void)listUnreadCount;

-(void)streamContentsWithFeed:(NSString *)feedUrl;
-(void)streamUnreadContentsWithFeed:(NSString *)feedUrl;
-(void)streamContentsWithId:(NSString *)streamId;
-(void)streamIdsWithId:(NSString *)streamId;

-(void)searchWithKeyword:(NSString *)keyword;

@end
