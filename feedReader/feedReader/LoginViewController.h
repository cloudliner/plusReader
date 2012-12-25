//
//  LoginViewController.h
//  feedReader
//
//  Created by 大野 廉 on 2012/12/16.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIWebViewDelegate> {
  @private
    NSMutableData *responseData;
}
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end
