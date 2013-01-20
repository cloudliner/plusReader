//
//  CLRItemViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/16.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLRDetailViewController;
@class CLRStreamCursor;
@class CLRCoreData;

@interface CLRItemViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CLRStreamCursor* streamCursor;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CLRCoreData *coreData;

@property (strong, nonatomic) CLRDetailViewController *detailViewController;

@end
