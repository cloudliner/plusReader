//
//  CLRMasterViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRStreamViewController.h"

#import "CLRDetailViewController.h"
#import "CLRGoogleOAuth.h"
#import "CLRGRRetrieve.h"
#import "CLRTag.h"
#import "CLROrdering.h"
#import "CLRStreamCursor.h"
#import "CLRCoreData.h"

@interface CLRStreamViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CLRStreamViewController

- (void)awakeFromNib {
  // TODO: とりあえずiPhoneに限定
  /*
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
  }
  */
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  self.detailViewController = (CLRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
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
  // ツリーを生成する
  CLRGRRetrieve *grRetrieve = [[CLRGRRetrieve alloc] init];
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  CLRCoreData *coreData = self.coreData;
  
  // Orderingの取得・更新
  [grRetrieve listStreamPreference:^(NSDictionary *JSON) {
    NSDictionary *streamprefs = [JSON valueForKey:@"streamprefs"];
    NSMutableDictionary *orderings = [NSMutableDictionary dictionary];
    for (NSString *streamId in [streamprefs keyEnumerator]) {
      // 無関係の設定を除外
      // TODO: 不要かも...
      if ([streamId hasPrefix:@"feed"] ||
          [streamId hasPrefix:@"pop"]) {
        continue;
      }
      NSString *value = nil;
      NSArray *prefArray = [streamprefs valueForKey:streamId];
      for (NSDictionary *pref in prefArray) {
        NSString *prefKey = [pref valueForKey:@"id"] ;
        if ([prefKey isEqualToString:@"subscription-ordering"]) {
          value = [pref valueForKey:@"value"];
          break;
        }
      }
      if (value != nil) {
        CLROrdering *orderingObject = [coreData insertNewObjectForEntity:CLREntityOrdering];
        orderingObject.streamId = streamId;
        orderingObject.value = value;
        orderingObject.update = now;
        
        [orderings setObject:orderingObject forKey:streamId];
      }
    }
    
    // Tagの取得・更新
    [grRetrieve listTag:^(NSDictionary *JSON) {      
      NSArray *tags = [JSON valueForKey:@"tags"];
      for (NSDictionary *tag in tags) {
        NSString *streamId = [tag valueForKey:@"id"];
        
        NSString *sortidString = [tag valueForKey:@"sortid"];
        unsigned int sortid = CLRHexStringToUInt(sortidString);
        NSString *title = [tag valueForKey:@"title"];
        if (title == nil) {
          NSRange range = [streamId rangeOfString:@"/" options:NSBackwardsSearch];
          title = [streamId substringWithRange:NSMakeRange(range.location + 1, streamId.length - range.location - 1)];
        }
        
        CLRTag *tagObject = [coreData insertNewObjectForEntity:CLREntityTag];
        tagObject.streamId = streamId;
        tagObject.title = title;
        tagObject.sortId = sortid;
        tagObject.update = now;
        
        // 以下は組み込みとして扱う
        // "user/-/state/com.google/starred"
        // "user/-/state/com.google/broadcast"
        // "user/-/state/com.blogger/blogger-following"
        if ([streamId hasSuffix:@"/state/com.google/starred"] ||
            [streamId hasSuffix:@"/state/com.google/broadcast"] ||
            [streamId hasSuffix:@"/state/com.blogger/blogger-following"]) {
          tagObject.type = CLRTypeEnumerationTagEmbed;
        } else {
          tagObject.type = CLRTypeEnumerationTagNormal;
        }
        
        // ordering の設定
        CLROrdering *ordering = [orderings objectForKey:streamId];
        if (ordering != nil) {
          tagObject.ordering = ordering;
        }
      }
            
      // 古いオブジェクトを削除
      [coreData deleteForEntity:CLREntityTag timestamp:now];
      [coreData deleteForEntity:CLREntityOrdering timestamp:now];
      
      // TODO: Feedの取得・更新
      // TODO: 未読件数の更新
      // 保存
      [coreData saveContext];
      
      // StreamListの更新
      [self updateStreamList];
      
      // 保存
      [coreData saveContext];
    }];
  }];
  
  // 未使用メソッド
  /*
  // subscription/list
  [grRetrieve listSubscription];
  // preference/list
  [grRetrieve listPreference];
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

- (void)updateStreamList {
  // ルート階層を取得
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"update" ascending:YES];
  CLRCoreData *coreData = self.coreData;
  NSFetchRequest *orderingRequest = [[NSFetchRequest alloc] init];
  NSPredicate *orderingPredidate =  [NSPredicate predicateWithFormat:@"%K like %@", @"streamId", @"*/state/com.google/root"];
  [orderingRequest setPredicate:orderingPredidate];
  [orderingRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  NSFetchedResultsController *rootFetchedResultsController
  = [coreData copyFetchedResultsControllerWithEntity:CLREntityOrdering fetchRequest:orderingRequest];
  
  NSError *error = nil;
  if (![rootFetchedResultsController performFetch:&error]) {
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  CLROrdering* rootOrder = nil;
  NSArray *orderingArray = [rootFetchedResultsController fetchedObjects];
  for (CLROrdering *object in orderingArray) {
    rootOrder = object;
  }
  
  // TagからStreamListを更新
  NSPredicate *tagPredidate = [NSPredicate predicateWithFormat:@"type == %d", CLRTypeEnumerationTagNormal];
  
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  NSArray *tagArray = [coreData copyResultForEntity:CLREntityTag predicate:tagPredidate];
  for (CLRTag *tagObject in tagArray) {
    CLRStreamCursor *streamCursorObject = [coreData insertNewObjectForEntity:CLREntityStreamCursor];
    streamCursorObject.stream = tagObject;
    streamCursorObject.sortId = tagObject.sortId;
    streamCursorObject.type = CLRTypeEnumerationTagNormal;
    streamCursorObject.update = now;
    streamCursorObject.index = [rootOrder indexWithSortid:tagObject.sortId];
  }
  
  // TODO: FeedからStreamCursorを更新
  
  // 古いオブジェクトを削除
  [coreData deleteForEntity:CLREntityStreamCursor timestamp:now];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
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
  // TODO: Cellの種類を変更する
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
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
            CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
  // TODO: とりあえずiPhoneに限定
  /*
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = object;
  }
  */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // TODO: 遷移処理の変更
  if ([[segue identifier] isEqualToString:@"showItem"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    CLRStreamCursor *streamCursorObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[segue destinationViewController] setStreamCursor:streamCursorObject];
  }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSPredicate *predidate = [NSPredicate predicateWithFormat:@"type == %d", CLRTypeEnumerationTagNormal];
  [fetchRequest setPredicate:predidate];
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
  NSArray *sortDescriptors = @[sortDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  NSFetchedResultsController *aFetchedResultsController = [self.coreData copyFetchedResultsControllerWithEntity:CLREntityStreamCursor fetchRequest:fetchRequest];
  
  self.fetchedResultsController = aFetchedResultsController;
  aFetchedResultsController.delegate = self;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
  CLRStreamCursor *streamCursorObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
  CLRStream *streamObject = streamCursorObject.stream;
  cell.textLabel.text = streamObject.title;
}

@end
