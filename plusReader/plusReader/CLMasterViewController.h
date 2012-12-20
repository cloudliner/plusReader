//
//  CLMasterViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLDetailViewController;

#import <CoreData/CoreData.h>

@interface CLMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CLDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
