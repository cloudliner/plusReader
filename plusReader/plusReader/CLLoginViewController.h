//
//  CLLoginViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLBrowserView.h"

@interface CLLoginViewController : UIViewController<UIWebViewDelegate, CLBrowserViewDelegate> {
@private
  NSMutableData *_responseData; // TODO: 誰が後始末をするのか？
}

@property (nonatomic) CLBrowserView *browserView;

@end
