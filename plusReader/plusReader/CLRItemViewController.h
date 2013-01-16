//
//  CLRItemViewController.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/16.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLRDetailViewController;

@interface CLRItemViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id streamList;

@property (strong, nonatomic) CLRDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
