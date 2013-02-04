//
//  CLRDetailViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLRDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

// TODO: 暫定的にWebViewに表示
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;

@end
