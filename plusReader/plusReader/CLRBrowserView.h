//
//  CLRBrowserView.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/30.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLRBrowserViewDelegate;

@interface CLRBrowserView : UIView <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) id<CLRBrowserViewDelegate> delegate;

@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIWebView *webView;

- (void)loadRequest:(NSURLRequest *)request;

@end

@protocol CLRBrowserViewDelegate <NSObject>
-(void)closeBrowser;
@optional
@end