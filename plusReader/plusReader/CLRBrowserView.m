//
//  CLRBrowserView.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/30.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRBrowserView.h"

// TODO: 定数の持ち方
#define kNavigationBar 44.0f

@interface CLRBrowserView()
- (void)clearNavigationBar;
- (void)clearWebView;
@end

@implementation CLRBrowserView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  if (self) {
    [self clearNavigationBar];
    CGRect frameOfNavigation = CGRectMake(0, -kNavigationBar, self.frame.size.width, kNavigationBar);
    _navigationBar = [[UINavigationBar alloc] initWithFrame:frameOfNavigation];
    _navigationBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    _navigationBar.barStyle = UIBarStyleBlack;
    
    // ボタンの追加
    UINavigationItem *navigationItem = [UINavigationItem alloc];
    [_navigationBar pushNavigationItem:navigationItem animated:NO];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(closeBrowser)];
    navigationItem.leftBarButtonItem = cancelButton;
    
    [self clearWebView];
    _webView = [[UIWebView alloc] initWithFrame:self.bounds];
    _webView.delegate = self;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    
    for (id subview in _webView.subviews) {
      if ([subview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)subview;
        scrollView.delegate = self;
        scrollView.contentInset = UIEdgeInsetsMake(frameOfNavigation.size.height, 0, 0, 0);
        [scrollView setContentOffset:CGPointMake(0, frameOfNavigation.origin.y) animated:NO];
        [scrollView addSubview:_navigationBar];
      }
    }
    [self addSubview:_webView];
  }
  return self;
}

-(void) closeBrowser {
  CLRLog(@"");
  [self.delegate closeBrowser];
}

-(void)loadRequest:(NSURLRequest *)request {
  if (_webView != nil) {
    [_webView loadRequest:request];
  }
}

- (void)clearNavigationBar {
  _navigationBar = nil;
}

- (void)clearWebView {
  if (_webView != nil) {
    _webView.delegate = nil;
  }
  _webView = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *) webView {
  for (id subview in webView.subviews) {
    if ([subview isKindOfClass:[UIScrollView class]]) {
      UIScrollView *scrollView = (UIScrollView *)subview;
      [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
  }
}

- (void)scrollViewDidScroll:(UIScrollView *) scrollView {
  if (scrollView.contentOffset.y < 0) {
    UIEdgeInsets insects = scrollView.scrollIndicatorInsets;
    insects.top = -scrollView.contentOffset.y;
    scrollView.scrollIndicatorInsets = insects;
  }
}

@end
