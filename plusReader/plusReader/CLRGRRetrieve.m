//
//  CLRGRRetrieve.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/05.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRGRRetrieve.h"
#import "CLRGoogleOAuth.h"

@implementation CLRGRRetrieve

-(id)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.google.com/"]];
  _queue = [[NSOperationQueue alloc] init];
  _credential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
  
  return self;
}

-(void)setTokenToRequest:(NSMutableURLRequest *)request {
  [request setValue:[NSString stringWithFormat:@"%@ %@",
                     self.credential.tokenType,
                     self.credential.accessToken] forHTTPHeaderField:@"Authorization"];
}

-(void)listTag:(CLGRRetrieveSuccessBlock)successBlock {
  // tag/list
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:@"https://www.google.com/reader/api/0/tag/list?output=json"
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                    successBlock(json);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)listSubscription:(CLGRRetrieveSuccessBlock)successBlock {
  // subscription/list
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:@"https://www.google.com/reader/api/0/subscription/list?output=json"
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                    successBlock(json);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)listPreference {
  // preference/list
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:@"https://www.google.com/reader/api/0/preference/list?output=json"
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];  
}

-(void)listStreamPreference:(CLGRRetrieveSuccessBlock)successBlock {
  // preference-stream
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:@"https://www.google.com/reader/api/0/preference/stream/list?output=json"
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                    successBlock(json);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)listUnreadCount:(CLGRRetrieveSuccessBlock)successBlock {
  // unread-count
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:@"https://www.google.com/reader/api/0/unread-count?output=json"
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                    successBlock(json);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)streamContentsWithFeed:(NSString *)feedUrl {
  // stream-contents-feed
  
  NSMutableString *path = [NSMutableString string];
  [path appendString:@"http://www.google.com/reader/api/0/stream/contents/"];
  // TODO: feed/ の扱いについて要検討
  if (![feedUrl hasPrefix:@"feed"]) {
    [path appendString:CLREncodeURL(@"feed/")];
  }
  [path appendString:CLREncodeURL(feedUrl)];
  [path appendFormat:@"?n=%d", 10];
  
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:path
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
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
  [path appendFormat:@"?n=%d", 10];
  [path appendFormat:@"&xt=%@", CLREncodeURL(@"user/-/state/com.google/read")];

  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:path
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)streamContentsWithId:(NSString *)streamId {
  // stream-contents-reading-list
  // stream-contents-starred
  // stream-contents-tag

  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/stream/contents/"];
  [path appendString:CLREncodeURL(streamId)];
  [path appendFormat:@"?n=%d", 10];
  
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:path
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  
  [self.queue addOperation:operation];
}

-(void)streamIdsWithId:(NSString *)streamId {
  // stream-ids-read

  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/stream/items/ids?s="];
  [path appendString:CLREncodeURL(streamId)];
  [path appendFormat:@"&output=json&n=%d", 40];

  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                         path:path
                                                   parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

-(void)searchWithKeyword:(NSString *)keyword {
  // search-ids
  NSMutableString *path = [NSMutableString string];
  [path appendString:@"https://www.google.com/reader/api/0/search/items/ids?q="];
  [path appendString:CLREncodeURL(keyword)];
  [path appendFormat:@"&output=json&num=%d", 20];
  
  NSMutableURLRequest *request =[self.httpClient requestWithMethod:@"GET"
                                                              path:path
                                                        parameters:nil];
  
  [self setTokenToRequest:request];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    NSDictionary *json = (NSDictionary *)JSON;
                                                    CLRLog(@"success:%@ %@", request.description, json.description);
                                                    NSArray *idList = json[@"results"];
                                                    
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
                                                    
                                                    [self setTokenToRequest:contentsRequest];
                                                    
                                                    AFJSONRequestOperation *contentsOperation =
                                                    [AFJSONRequestOperation JSONRequestOperationWithRequest:contentsRequest
                                                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                      NSDictionary *json = (NSDictionary *)JSON;
                                                                                                      CLRLog(@"success:%@ %@", request.description, json.description);
                                                                                                    }
                                                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                      CLRLog(@"failure:%@ %@", request.description, error.description);
                                                                                                    }];
                                                    
                                                    [self.queue addOperation:contentsOperation];
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    CLRLog(@"failure:%@ %@", request.description, error.description);
                                                  }];
  
  [self.queue addOperation:operation];
}

@end
