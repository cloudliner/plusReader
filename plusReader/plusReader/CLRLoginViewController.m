//
//  CLRLoginViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRLoginViewController.h"
#import "CLRAppDelegate.h"
#import "CLRGoogleOAuth.h"

@interface CLRLoginViewController ()

@end

@implementation CLRLoginViewController

- (void)closeBrowser {
  CLRLog(@"");
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
  
  self.browserView = [[CLRBrowserView alloc] initWithFrame:self.view.bounds];
  self.browserView.delegate = self;
  [self.view addSubview:self.browserView];
    
  UIWebView *webView = self.browserView.webView;
  [webView setDelegate:self];
  NSMutableString *path = [NSMutableString stringWithCapacity: 0];
  [path appendString:@"https://accounts.google.com/o/oauth2/auth"];
  [path appendString:@"?response_type=code"];
  [path appendFormat:@"&scope=%@", GOOGLE_OAUTH2_SCOPE];
  [path appendFormat:@"&redirect_uri=%@", GOOGLE_OAUTH2_REDIRECT_URIS];
  [path appendFormat:@"&client_id=%@", GOOGLE_OAUTH2_CLIENT_ID];
  
  [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
  
  CLRGAITrack();
}

- (BOOL)webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
  NSString *url = [request.URL absoluteString];
  CLRLog(@"URL:%@", url);
  if ([url hasPrefix:@"https://accounts.google.com/o/oauth2/approval"]) {
    CLRLog(@"requesting...");
    [NSURLConnection connectionWithRequest:request delegate:self];
    return NO;
  }
  return YES;
}

- (void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response {
  CLRLog(@"");
  _responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data {
  CLRLog(@"");
  [_responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection*) connection {
  NSString* code = [self extractCode:_responseData];
  CLRLog(@"code=%@", code);
  if (code != nil) {
    [self getOAuthAccessToken:code];
  } else {
    CLRLog(@"OAuth failed.");
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
  CLRAppDelegate *delegate = (CLRAppDelegate *) [[UIApplication sharedApplication] delegate];
  
  [delegate.googleOAuthClient authenticateUsingOAuthWithPath:@"https://accounts.google.com/o/oauth2/token"
                                                        code:code
                                                 redirectURI:GOOGLE_OAUTH2_REDIRECT_URIS
                                                     success:^(AFOAuthCredential *credential) {
                                                       CLRLog(@"success:%@", credential.description);
                                                       
                                                       // 認証データを保存
                                                       [AFOAuthCredential storeCredential:credential
                                                                           withIdentifier:GOOGLE_OAUTH2_STORE_NAME];
                                                       
                                                       // ダイアログを閉じる
                                                       [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                       
                                                     } failure:^(NSError *error) {
                                                       CLRLog(@"failure:%@", error.description);
                                                       
                                                     }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
