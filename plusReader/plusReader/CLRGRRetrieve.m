//
//  CLRGRRetrieve.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/05.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRGRRetrieve.h"
#import "CLRAppDelegate.h"
#import "CLRGoogleOAuth.h"
#import "FBNetworkReachability.h"

@implementation CLRGRRetrieve

-(id)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.google.com/"]];
  _queue = [[NSOperationQueue alloc] init];
  
  return self;
}

-(void)retrieveJSONWithAuthorizationRequest:(NSMutableURLRequest *)request success:(CLGRRetrieveSuccessBlock)successBlock {
  // ネットワーク接続チェック
  if ([FBNetworkReachability sharedInstance].reachable) {
    // 認証チェック
    AFOAuthCredential *storedCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
    CLRLog(@"storedCredential expired=%d", storedCredential.expired);
    if (storedCredential.expired) {
      // 認証をリフレッシュ
      CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
      AFOAuth2Client *googleOAuthClient = delegate.googleOAuthClient;
      [googleOAuthClient authenticateUsingOAuthWithPath:@"https://accounts.google.com/o/oauth2/token"
                                           refreshToken:storedCredential.refreshToken
                                                success:^(AFOAuthCredential *credential) {
                                                  CLRLog(@"success:%@", credential.description);
                                                  // 認証データを保存
                                                  [AFOAuthCredential storeCredential:credential
                                                                      withIdentifier:GOOGLE_OAUTH2_STORE_NAME];
                                                  
                                                  [self retrieveJSONWithRequest:request success:successBlock];
                                                } failure:^(NSError *error) {
                                                  CLRLog(@"failure:%@", error.description);
                                                  CLRGAITrackException(error);
                                                }];
    } else {
      [self retrieveJSONWithRequest:request success:successBlock];
    }
  } else {
    // TODO: ネットワーク接続がない場合の実装
    CLRLog(@"No Network Connection.");
  }
}

-(void)retrieveJSONWithRequest:(NSMutableURLRequest *)request success:(CLGRRetrieveSuccessBlock)successBlock {
  // 認証情報を取得・設定
  AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
  NSString *scheme = request.URL.scheme;
  if (credential != nil && [scheme isEqualToString:@"https"]) {
    [request setValue:[NSString stringWithFormat:@"%@ %@",
                       credential.tokenType,
                       credential.accessToken] forHTTPHeaderField:@"Authorization"];
  }
  
  // ネットワーク接続チェック
  if ([FBNetworkReachability sharedInstance].reachable) {
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                               NSDictionary *json = (NSDictionary *)JSON;
                               // CLRLog(@"success:%@ %@", request.description, json.description);
                               CLRLog(@"success:%@", request.description);
                               successBlock(json);
                             }
                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                               CLRLog(@"failure:%@ %@", request.description, error.description);
                               CLRGAITrackException(error);
                             }];
    
    [self.queue addOperation:operation];
  } else {
    // TODO: ネットワーク接続がない場合の実装
    CLRLog(@"No Network Connection.");
  }
}

-(void)listTag:(CLGRRetrieveSuccessBlock)successBlock {
  // tag/list
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:@"https://www.google.com/reader/api/0/tag/list?output=json"
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request success:successBlock];
}

-(void)listSubscription:(CLGRRetrieveSuccessBlock)successBlock {
  // subscription/list
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:@"https://www.google.com/reader/api/0/subscription/list?output=json"
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request success:successBlock];
}

-(void)listPreference {
  // preference/list
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:@"https://www.google.com/reader/api/0/preference/list?output=json"
                          parameters:nil];
  
  // TODO: 処理作成
  [self retrieveJSONWithAuthorizationRequest:request success:nil];
}

-(void)listStreamPreference:(CLGRRetrieveSuccessBlock)successBlock {
  // preference-stream
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:@"https://www.google.com/reader/api/0/preference/stream/list?output=json"
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request success:successBlock];
}

-(void)listUnreadCount:(CLGRRetrieveSuccessBlock)successBlock {
  // unread-count
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:@"https://www.google.com/reader/api/0/unread-count?output=json"
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request success:successBlock];
}

-(void)streamContentsWithFeed:(NSString *)feedUrl success:(CLGRRetrieveSuccessBlock)successBlock {
  // stream-contents-feed
  
  NSMutableString *path = [NSMutableString string];
  [path appendString:@"http://www.google.com/reader/api/0/stream/contents/"];
  // TODO: feed/ の扱いについて要検討
  if (![feedUrl hasPrefix:@"feed"]) {
    [path appendString:CLREncodeURL(@"feed/")];
  }
  [path appendString:CLREncodeURL(feedUrl)];
  [path appendFormat:@"?n=%d", 20];
  
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:path
                          parameters:nil];
  
  [self retrieveJSONWithRequest:request success:successBlock];
}

-(void)streamUnreadContentsWithFeed:(NSString *)feedUrl {
  // stream-contents-feed-unread
  
  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/stream/contents/"];
  // TODO: feed/ の扱いについて要検討
  if (![feedUrl hasPrefix:@"feed"]) {
    [path appendString:CLREncodeURL(@"feed/")];
  }
  [path appendString:CLREncodeURL(feedUrl)];
  [path appendFormat:@"?n=%d", 20];
  [path appendFormat:@"&xt=%@", CLREncodeURL(@"user/-/state/com.google/read")];

  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:path
                          parameters:nil];
  
  // TODO: 処理作成
  [self retrieveJSONWithAuthorizationRequest:request success:nil];
}

-(void)streamContentsWithId:(NSString *)streamId success:(CLGRRetrieveSuccessBlock)successBlock {
  // stream-contents-reading-list
  // stream-contents-starred
  // stream-contents-tag

  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/stream/contents/"];
  [path appendString:CLREncodeURL(streamId)];
  [path appendFormat:@"?n=%d", 20];
  
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:path
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request success:successBlock];
}

-(void)streamIdsWithId:(NSString *)streamId {
  // stream-ids-read

  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/stream/items/ids?s="];
  [path appendString:CLREncodeURL(streamId)];
  [path appendFormat:@"&output=json&n=%d", 40];

  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:path
                          parameters:nil];
  
  // TODO: 処理作成
  [self retrieveJSONWithAuthorizationRequest:request success:nil];
}

-(void)searchWithKeyword:(NSString *)keyword {
  // search-ids
  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/search/items/ids?q="];
  [path appendString:CLREncodeURL(keyword)];
  [path appendFormat:@"&output=json&num=%d", 20];
  
  NSMutableURLRequest *request =
  [self.httpClient requestWithMethod:@"GET"
                                path:path
                          parameters:nil];
  
  [self retrieveJSONWithAuthorizationRequest:request
                           success:^(NSDictionary *JSON) {
                             NSArray *idList = JSON[@"results"];
                                                    
                             // TODO: 複数パラメータの送信
                             // NSMutableArray *idArray = [NSMutableArray array];
                             // for (NSDictionary *idItem in idList) {
                             //   [idArray addObject:idItem[@"id"]];
                             // }
                             // NSMutableDictionary *params = [NSMutableDictionary dictionary];
                             // [params setObject:idArray forKey:@"i"];
                             
                             NSMutableString *path = [NSMutableString string];
                             [path appendString:@"https://www.google.com/reader/api/0/stream/items/contents?output=json"];
                             for (NSDictionary *idItem in idList) {
                               [path appendFormat:@"&i=%@", idItem[@"id"]];
                             }
                             
                             // search-contents
                             NSMutableURLRequest *contentsRequest =[self.httpClient requestWithMethod:@"GET"
                                                                                                 path:path
                                                                                           parameters:nil];
                             
                             [self retrieveJSONWithAuthorizationRequest:contentsRequest
                                                                success:^(NSDictionary *JSON) {
                                                                  NSDictionary *json = (NSDictionary *)JSON;
                                                                  // TODO: 処理作成
                                                                }];
                           }];
}

@end
