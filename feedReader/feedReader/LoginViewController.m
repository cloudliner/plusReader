//
//  LoginViewController.m
//  feedReader
//
//  Created by 大野 廉 on 2012/12/16.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MasterViewController.h"
#import "AFNetworking.h"
#import "AFOAuth2Client.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization      
    }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  _userId.text = delegate.userId;
  _password.text = delegate.password;
  [_webView setDelegate:self];

  NSString* path = @"https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.google.com%2Freader%2Fapi&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=395579589262-1mjtb26qvvr55udvvmjo1e565h2q89k6.apps.googleusercontent.com";
  [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
  NSString *url = [request.URL absoluteString];
  NSLog(@"URL:%@", url);
  if ([url hasPrefix:@"https://accounts.google.com/o/oauth2/approval"]) {
    NSLog(@"requesting...");
    [NSURLConnection connectionWithRequest:request delegate:self];
    return NO;
  }
  return YES;
}

- (void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response {
  NSLog(@"didReceiveResponse");
  responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data {
  NSLog(@"didReceiveData");
  [responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection*) connection {
  NSString* pin = [self extractPin:responseData];
  NSLog(@"connectionDidFinishLoading:pin=%@", pin);
  if ( pin != nil ) {
    [self getOAuthAccessToken:pin];
  } else {
    NSLog(@"OAuth failed.");
  }
}

- (NSString*) extractPin:(NSMutableData*) data {
  NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSRange searchResult = [response rangeOfString:@"<input id=\"code\" type=\"text\" readonly=\"readonly\" value=\""];
  if ( searchResult.location != NSNotFound ) {
    NSRange range = NSMakeRange(searchResult.location + searchResult.length, 62);
    return [response substringWithRange:range];
  } else {
    return nil;
  }
}

-(void)getOAuthAccessToken:(NSString*) verifier {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:verifier forKey:@"code"];
  [params setObject:@"authorization_code" forKey:@"grant_type"];
  [params setObject:@"395579589262-1mjtb26qvvr55udvvmjo1e565h2q89k6.apps.googleusercontent.com" forKey:@"client_id"];
  [params setObject:@"xjUtWxO7dkz46DqcstpBWWHu" forKey:@"client_secret"];
  [params setObject:@"urn:ietf:wg:oauth:2.0:oob" forKey:@"redirect_uri"];

  NSURL *url = [NSURL URLWithString:@"https://accounts.google.com/"];
  AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
  
  [httpClient postPath:@"https://accounts.google.com/o/oauth2/token"
            parameters:params
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"OAuth success.");
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"OAuth failed.");
               }];
}

- (IBAction)closeModalDialog:(id)sender {
  //モーダルViewを表示したViewControllerに対してdismissメッセージを送信する。
  //[self presentingViewController]で遷移前のViewControllerを取得しています。
  AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  delegate.userId = _userId.text;
  delegate.password = _password.text;
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
