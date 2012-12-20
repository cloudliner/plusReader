//
//  DetailViewController.h
//  feedReader
//
//  Created by 大野 廉 on 2012/12/15.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
