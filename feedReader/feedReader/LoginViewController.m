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
//    [_google requestOAuthAccessToken:request];
    return NO;
  }
  return YES;
}

- (IBAction)closeModalDialog:(id)sender {
  //モーダルViewを表示したViewControllerに対してdismissメッセージを送信する。
  //[self presentingViewController]で遷移前のViewControllerを取得しています。
  AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  delegate.userId = _userId.text;
  delegate.password = _password.text;
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) oAuthFailed {
  NSLog(@"OAuth failed.");
}

@end
