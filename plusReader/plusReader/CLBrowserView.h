//
//  CLBrowserView.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/30.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLBrowserViewDelegate;

@interface CLBrowserView : UIView <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) id<CLBrowserViewDelegate> delegate;

@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIWebView *webView;

- (void)loadRequest:(NSURLRequest *)request;

@end

@protocol CLBrowserViewDelegate <NSObject>
-(void)closeBrowser;
@optional
@end