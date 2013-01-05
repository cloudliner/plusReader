//
//  CLMasterViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLMasterViewController.h"

#import "CLDetailViewController.h"
#import "CLGoogleOAuth.h"
#import "CLGRRetrieve.h"

@interface CLMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CLMasterViewController

- (void)awakeFromNib {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
  }
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  self.detailViewController = (CLDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  // GAI
  /*
  [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"Master"
                                                   withAction:@"load"
                                                    withLabel:nil
                                                    withValue:nil];
  */
  
  // OpenConfig
  AFOAuthCredential *storedCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
  if (storedCredential == nil) {
    [self performSegueWithIdentifier:@"openConfigView" sender:self];
  }
}

- (IBAction)loadFeeds:(id)sender {
  // フィードを読み込む
  CLGRRetrieve *grRetrieve = [[CLGRRetrieve alloc] init];
  
  // List API
  // tag/list
  [grRetrieve listTag:^(NSDictionary *JSON) {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSArray *tags = [JSON valueForKey:@"tags"];
    
    NSDate *now = [NSDate date];
    for (NSDictionary *tag in tags) {
      // TODO: 以下のidのタグを除外
      // "user/-/state/com.google/starred"
      // "user/-/state/com.google/broadcast"
      // "user/-/state/com.blogger/blogger-following"

      NSString *idString = [tag valueForKey:@"id"];
      NSString *sortidString = [tag valueForKey:@"sortid"];
      NSNumber *sortid = [NSNumber numberWithUnsignedInt:CLHexStringToUInt(sortidString)];
      NSString *title = [tag valueForKey:@"title"];
      if (title == nil) {
        NSRange range = [idString rangeOfString:@"/" options:NSBackwardsSearch];
        title = [idString substringWithRange:NSMakeRange(range.location + 1, idString.length - range.location - 1)];
      }
      
      NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
      [newManagedObject setValue:idString forKey:@"id"];
      [newManagedObject setValue:title forKey:@"title"];
      [newManagedObject setValue:sortid forKey:@"sortid"];
      [newManagedObject setValue:now forKey:@"update"];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      CLLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
    
    // 古いオブジェクトを削除
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"update" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *predidate = [NSPredicate predicateWithFormat:@"update != %@", now];
    [fetchRequest setPredicate:predidate];
    
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:context
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    if (![fetchedResultsController performFetch:&error]) {
      CLLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
    
    NSArray *arrayToDelete = [fetchedResultsController fetchedObjects];
    for (NSManagedObject *object in arrayToDelete) {
      [context deleteObject:object];
    }
  }];
  
  /*
  // subscription/list
  [grRetrieve listSubscription];
  // preference/list
  [grRetrieve listPreference];
  // preference-stream
  [grRetrieve listStreamPreference];
  // unread-count
  [grRetrieve listUnreadCount];
  
  // Stream Contents API
  // stream-contents-feed
  [grRetrieve streamContentsWithFeed:@"feed/http://lkhjkljkljdkljl.hatenablog.com/feed"];
  // stream-contents-feed-unread
  [grRetrieve streamUnreadContentsWithFeed:@"feed/http://lkhjkljkljdkljl.hatenablog.com/feed"];
  // stream-contents-reading-list
  [grRetrieve streamContentsWithId:@"user/-/state/com.google/reading-list"];
  // stream-contents-starred
  [grRetrieve streamContentsWithId:@"user/-/state/com.google/starred"];
  // stream-contents-tag
  [grRetrieve streamContentsWithId:@"user/-/label/Business"];
  
  // Stream Items API
  // stream-ids-read
  [grRetrieve streamIdsWithId:@"user/-/state/com.google/read"];
  
  // Search
  [grRetrieve searchWithKeyword:@"iPad"];
  */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  // TODO: 編集処理の実装
  return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // The table view should not be re-orderable.
  // TODO: 並び替え処理の実装
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = object;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[segue destinationViewController] setDetailItem:object];
  }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize:20];
  
  // Edit the sort key as appropriate.
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
  
  // TODO: comparator blocks are not supported
  /*
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                 ascending:YES
                                                                comparator:^NSComparisonResult(id obj1, id obj2) {
                                                                  NSNumber *n1 = [obj1 valueForKey:@"sortid"];
                                                                  unsigned int ui1 = [n1 unsignedIntValue];
                                                                  NSNumber *n2 = [obj2 valueForKey:@"sortid"];
                                                                  unsigned int ui2 = [n2 unsignedIntValue];
                                                                  // TODO: 配列のデータを取得してソートする
                                                                  return [n1 compare:n2];
                                                                }];
  */
  NSArray *sortDescriptors = @[sortDescriptor];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
  aFetchedResultsController.delegate = self;
  self.fetchedResultsController = aFetchedResultsController;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  
  return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  UITableView *tableView = self.tableView;
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = [[object valueForKey:@"title"] description];
}

@end
