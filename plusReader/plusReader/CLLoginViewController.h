//
//  CLLoginViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLLoginViewController : UIViewController<UIWebViewDelegate> {
@private
  NSMutableData *_responseData; // TODO: 誰が後始末をするのか？
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
