//
//  CLLoginViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLLoginViewController.h"
#import "CLAppDelegate.h"
#import "CLConsole.h"
#import "CLGoogleOAuth.h"

@interface CLLoginViewController ()

@end

@implementation CLLoginViewController

- (IBAction)closeModalDialog:(id)sender {
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [_webView setDelegate:self];
  NSMutableString *path = [NSMutableString stringWithCapacity: 0];
  [path appendString:@"https://accounts.google.com/o/oauth2/auth"];
  [path appendString:@"?response_type=code"];
  [path appendFormat:@"&scope=%@", GOOGLE_OAUTH2_SCOPE];
  [path appendFormat:@"&redirect_uri=%@", GOOGLE_OAUTH2_REDIRECT_URIS];
  [path appendFormat:@"&client_id=%@", GOOGLE_OAUTH2_CLIENT_ID];
  
  [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}

- (BOOL)webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
  NSString *url = [request.URL absoluteString];
  CLConsole(@"URL:%@", url);
  if ([url hasPrefix:@"https://accounts.google.com/o/oauth2/approval"]) {
    CLConsole(@"requesting...");
    [NSURLConnection connectionWithRequest:request delegate:self];
    return NO;
  }
  return YES;
}

- (void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response {
  CLConsole(@"didReceiveResponse");
  _responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data {
  CLConsole(@"didReceiveData");
  [_responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection*) connection {
  NSString* code = [self extractCode:_responseData];
  CLConsole(@"connectionDidFinishLoading:code=%@", code);
  if (code != nil) {
    [self getOAuthAccessToken:code];
  } else {
    CLConsole(@"OAuth failed.");
  }
}

- (NSString*) extractCode:(NSMutableData*) data {
  NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSRange searchResult = [response rangeOfString:@"<input id=\"code\" type=\"text\" readonly=\"readonly\" value=\""];
  if ( searchResult.location != NSNotFound ) {
    NSRange range = NSMakeRange(searchResult.location + searchResult.length, 62);
    return [response substringWithRange:range];
  } else {
    return nil;
  }
}

-(void)getOAuthAccessToken:(NSString*) code {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:code forKey:@"code"];
  [params setObject:@"authorization_code" forKey:@"grant_type"];
  [params setObject:GOOGLE_OAUTH2_CLIENT_ID forKey:@"client_id"];
  [params setObject:GOOGLE_OAUTH2_CLIENT_SECRET forKey:@"client_secret"];
  [params setObject:GOOGLE_OAUTH2_REDIRECT_URIS forKey:@"redirect_uri"];

  AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://accounts.google.com/"]];

  NSMutableURLRequest *request =[httpClient requestWithMethod:@"POST"
                                                         path:@"https://accounts.google.com/o/oauth2/token"
                                                   parameters:params];
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
     NSDictionary *json = (NSDictionary *)JSON;
     CLConsole(@"responseObject:%@", [json description]);
     CLConsole(@"OAuth success.");
     
     CLAppDelegate *del = (CLAppDelegate *) [[UIApplication sharedApplication] delegate];
     del.access_token = [json valueForKey:@"access_token"];
     del.expires_in = [json valueForKey:@"expires_in"];
     del.refresh_token = [json valueForKey:@"refresh_token"];
     del.token_type = [json valueForKey:@"token_type"];
     
     [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
   }
   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
     //
     CLConsole(@"OAuth failed.");
   }];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  [queue addOperation:operation];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
