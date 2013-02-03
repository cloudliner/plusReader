//
//  CLRGRRetrieve.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/05.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CLGRRetrieveSuccessBlock)(NSDictionary* JSON);

@interface CLRGRRetrieve : NSObject

@property (strong, nonatomic) AFHTTPClient *httpClient;
@property (strong, nonatomic) NSOperationQueue *queue;

-(void)listTag:(CLGRRetrieveSuccessBlock)successBlock;
-(void)listSubscription:(CLGRRetrieveSuccessBlock)successBlock;
-(void)listPreference;
-(void)listStreamPreference:(CLGRRetrieveSuccessBlock)successBlock;
-(void)listUnreadCount:(CLGRRetrieveSuccessBlock)successBlock;

-(void)streamContentsWithFeed:(NSString *)feedUrl success:(CLGRRetrieveSuccessBlock)successBlock;
-(void)streamUnreadContentsWithFeed:(NSString *)feedUrl;
-(void)streamContentsWithId:(NSString *)streamId success:(CLGRRetrieveSuccessBlock)successBlock;
-(void)streamIdsWithId:(NSString *)streamId;

-(void)searchWithKeyword:(NSString *)keyword;

@end
