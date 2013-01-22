//
//  CLRMasterViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRStreamViewController.h"
#import "CLRGoogleOAuth.h"
#import "CLRAppDelegate.h"
#import "CLRGRRetrieve.h"
#import "CLRTag.h"
#import "CLRFeed.h"
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
  
  // TODO: 一旦削除（iPad版では必要かも...）
  // self.detailViewController = (CLRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  // 認証情報がなかったときにConfig画面を自動的に開く
  AFOAuthCredential *storedCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:GOOGLE_OAUTH2_STORE_NAME];
  if (storedCredential == nil) {
    [self performSegueWithIdentifier:@"openConfigView" sender:self];
  }
  
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  
  CLRGAITrack();
}

- (void)refreshOccured:(id)sender {
  [self refreshFeeds];
}

- (IBAction)loadFeeds:(id)sender {
  [self refreshFeeds];
}

- (void)refreshFeeds {
  // TODO: 読み込みタイミングを適切なものにする（起動時、ネットワーク接続時）
  // TODO: 削除・追加ではなく更新するようにする
  
  CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];  
  CLRGRRetrieve *grRetrieve = delegate.grRetrieve;
  CLRCoreData *coreData = delegate.coreData;
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  
  // Orderingの取得・更新
  [grRetrieve listStreamPreference:^(NSDictionary *JSON) {
    NSDictionary *streamprefs = JSON[@"streamprefs"];
    NSMutableDictionary *tempOrderings = [NSMutableDictionary dictionary];
    for (NSString *streamId in [streamprefs keyEnumerator]) {
      // 無関係の設定を除外
      // TODO: 不要かも...
      if ([streamId hasPrefix:@"feed"] ||
          [streamId hasPrefix:@"pop"]) {
        continue;
      }
      NSString *value = nil;
      NSArray *prefArray = streamprefs[streamId];
      for (NSDictionary *pref in prefArray) {
        NSString *prefKey = pref[@"id"] ;
        if ([prefKey isEqualToString:@"subscription-ordering"]) {
          value = pref[@"value"];
          break;
        }
      }
      if (value != nil) {
        CLROrdering *orderingObject = [coreData insertNewObjectForEntity:CLREntityOrdering];
        orderingObject.streamId = streamId;
        orderingObject.value = value;
        orderingObject.update = now;
        
        // 参照用に保持
        [tempOrderings setObject:orderingObject forKey:streamId];
      }
    }
    
    // Tagの取得・更新
    [grRetrieve listTag:^(NSDictionary *JSON) {
      NSMutableDictionary *tempTags = [NSMutableDictionary dictionary];
      NSArray *tags = JSON[@"tags"];
      for (NSDictionary *tag in tags) {
        NSString *streamId = tag[@"id"];
        NSString *sortidString = tag[@"sortid"];
        int sortid = CLRIntForHexString(sortidString);
        NSString *title = tag[@"title"];
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
        CLROrdering *ordering = [tempOrderings objectForKey:streamId];
        if (ordering != nil) {
          tagObject.ordering = ordering;
        }
        
        // 参照用に保持
        [tempTags setObject:tagObject forKey:streamId];
      }
            
      // Feedの取得・更新
      [grRetrieve listSubscription:^(NSDictionary *JSON) {
        NSMutableDictionary *tempFeeds = [NSMutableDictionary dictionary];
        NSArray *subscriptions = JSON[@"subscriptions"];
        for (NSDictionary *subscription in subscriptions) {
          NSString *streamId = subscription[@"id"];
          NSString *sortidString = subscription[@"sortid"];
          int sortid = CLRIntForHexString(sortidString);
          NSString *title = subscription[@"title"];
          NSString *htmlUrl = subscription[@"htmlUrl"];
          
          CLRFeed *feedObject = [coreData insertNewObjectForEntity:CLREntityFeed];
          feedObject.streamId = streamId;
          feedObject.sortId = sortid;
          feedObject.title = title;
          feedObject.htmlUrl = htmlUrl;
          feedObject.update = now;
          
          // categories の設定
          NSArray *categories = subscription[@"categories"];
          for (NSDictionary *category in categories) {
            NSString *categoryId = category[@"id"];
            CLRTag *tagObject = tempTags[categoryId];
            if (tagObject != nil) {
              [feedObject addTagObject:tagObject];
            }
          }
          
          // 参照用に保持
          [tempFeeds setObject:feedObject forKey:streamId];
        }
        // 未読件数の更新
        [grRetrieve listUnreadCount:^(NSDictionary *JSON) {
          NSArray *unreadcounts = JSON[@"unreadcounts"];
          for (NSDictionary *unreadcount in unreadcounts) {
            NSString *streamId = unreadcount[@"id"];
            NSString *countString = unreadcount[@"count"];
            int count = [countString intValue];
            CLRTag *tagObject = tempTags[streamId];
            if (tagObject != nil) {
              tagObject.unreadCount = count;
            }
            CLRFeed *feedObject = tempFeeds[streamId];
            if (feedObject != nil) {
              feedObject.unreadCount = count;
            }
          }
          
          // 古いオブジェクトを削除
          [coreData deleteForEntity:CLREntityFeed timestamp:now];
          [coreData deleteForEntity:CLREntityTag timestamp:now];
          [coreData deleteForEntity:CLREntityOrdering timestamp:now];
          
          // StreamListの更新
          [self updateStreamList];
          
          // 保存
          [coreData saveContext];
          
          [self.refreshControl endRefreshing];
        }];
      }];
    }];
  }];
  
  // 未使用メソッド
  /*
  // preference/list
  [grRetrieve listPreference];
  
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
  CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
  CLRCoreData *coreData = delegate.coreData;
  
  // ルート階層を取得
  CLROrdering* rootOrder = nil;
  NSArray *orderingArray = [coreData arrayForEntity:CLREntityOrdering predicate:nil];
  for (CLROrdering *object in orderingArray) {
    if ([object.streamId hasSuffix:@"/state/com.google/root"]) {
      rootOrder = object;
    }
  }
    
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

  // TagからStreamListを更新
  NSPredicate *tagPredidate = [NSPredicate predicateWithFormat:@"type == %d", CLRTypeEnumerationTagNormal];
  NSArray *tagArray = [coreData arrayForEntity:CLREntityTag predicate:tagPredidate];
  for (CLRTag *tagObject in tagArray) {
    CLRStreamCursor *streamCursorObject = [coreData insertNewObjectForEntity:CLREntityStreamCursor];
    streamCursorObject.stream = tagObject;
    streamCursorObject.sortId = tagObject.sortId;
    streamCursorObject.type = CLRTypeEnumerationTagNormal;
    streamCursorObject.update = now;
    streamCursorObject.index = [rootOrder indexWithSortId:tagObject.sortId];
  }
  
  // FeedからStreamCursorを更新
  NSArray *feedArray = [coreData arrayForEntity:CLREntityFeed predicate:nil];
  for (CLRFeed *feedObject in feedArray) {
    int rootIndex = [rootOrder indexWithSortId:feedObject.sortId];
    if (rootIndex != -1) {
      CLRStreamCursor *streamCursorObject = [coreData insertNewObjectForEntity:CLREntityStreamCursor];
      streamCursorObject.stream = feedObject;
      streamCursorObject.sortId = feedObject.sortId;
      streamCursorObject.type = CLRTypeEnumerationFeedNormal;
      streamCursorObject.update = now;
      streamCursorObject.index = rootIndex;     
    }
  }
  
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
  // Cellの種類を変更する
  UITableViewCell *cell = nil;
  CLRStreamCursor *streamCursorObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
  switch (streamCursorObject.type) {
    case CLRTypeEnumerationFeedNormal:
      cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
      break;
    default:
      cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
      break;
  }
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
  if ([[segue identifier] isEqualToString:@"showTagItems"] ||
      [[segue identifier] isEqualToString:@"showFeedItems"]) {
    CLRLog(@"sender:%@", [sender description]);
    UIButton *countButton = sender;
    UITableViewCell *cell = (UITableViewCell *)[[countButton superview] superview];
    CLRLog(@"superview:%@", [cell description]);
    // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
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
  NSArray *predidateArray = @[@(CLRTypeEnumerationTagNormal), @(CLRTypeEnumerationFeedNormal)];
  NSPredicate *predidate = [NSPredicate predicateWithFormat:@"type IN %@", predidateArray];
  [fetchRequest setPredicate:predidate];
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
  NSArray *sortDescriptors = @[sortDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSFetchedResultsController *aFetchedResultsController = [delegate.coreData fetchedResultsControllerWithEntity:CLREntityStreamCursor fetchRequest:fetchRequest];
  
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

  UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
  UIButton *countButton = (UIButton*)[cell viewWithTag:3];
  
  titleLabel.text = streamObject.title;
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  NSDictionary* countStyle = @{NSParagraphStyleAttributeName: paragraphStyle};
  NSAttributedString *countString =
  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", streamObject.unreadCount]
                                  attributes:countStyle];
  [countButton setAttributedTitle:countString forState:UIControlStateNormal];
  // TODO: アイコン表示
}

@end
