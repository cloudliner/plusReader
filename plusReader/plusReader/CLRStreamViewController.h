//
//  CLRMasterViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLRDetailViewController;
@class CLRCoreData;

#import <CoreData/CoreData.h>

@interface CLRStreamViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CLRDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CLRCoreData *coreData;

@end
