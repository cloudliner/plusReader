//
//  CLRItemViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/16.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRItemViewController.h"
#import "CLRAppDelegate.h"
#import "CLRCoreData.h"
#import "CLRStreamCursor.h"
#import "CLRStream.h"
#import "CLRItemCursor.h"
#import "CLRItem.h"
#import "CLRGRRetrieve.h"

@interface CLRItemViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CLRItemViewController

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // TODO: 処理作成
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  self.refreshControl = refreshControl;
  
  CLRGAITrack();
}

- (void)setStreamCursor:(CLRStreamCursor *)streamCursor {
  if (_streamCursor != streamCursor) {
    _streamCursor = streamCursor;
    
    // 表示を更新
    NSString *streamId = streamCursor.stream.streamId;
    int32_t sortId = streamCursor.sortId;
   
    CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
    CLRGRRetrieve *grRetrieve = delegate.grRetrieve;
    CLRCoreData *coreData = delegate.coreData;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    // Orderingの取得・更新
    [grRetrieve streamContentsWithId:streamId success:^(NSDictionary *JSON) {
      // TODO: 以下の情報の扱い
      // author = cloudliner;
      // continuation = "CP3-zqm1y7QC";
      // direction = ltr;

      NSArray *items = JSON[@"items"];
      for (NSDictionary *item in items) {
        NSString *itemIdString = item[@"id"];
        // TODO: "tag:google.com,2005:reader/item/cf0922f5af194500" から int64_t型への変換
        
        NSString *timestampUsec = item[@"timestampUsec"];
        int64_t timestamp = [timestampUsec longLongValue];

        CLRItemCursor *itemCursorObject = [coreData insertNewObjectForEntity:CLREntityItemCursor];
        [itemCursorObject setItemIdForString:itemIdString];
        itemCursorObject.sortId = sortId;
        itemCursorObject.timestamp = timestamp;
        itemCursorObject.type = CLRTypeEnumerationItemNormal;
        itemCursorObject.update = now;
        
        CLRItem *itemObject = [coreData insertNewObjectForEntity:CLREntityItem];
        itemCursorObject.item = itemObject;
        itemObject.title = item[@"title"];
        itemObject.content = item[@"content"][@"content"];
        // TODO: 処理作成
        
        itemObject.update = now;
      }
      
      // 古いオブジェクトを削除
      // 削除するタイミング
      [coreData deleteForEntity:CLREntityItemCursor timestamp:now];
      [coreData deleteForEntity:CLREntityItem timestamp:now];
      
      // 保存
      [coreData saveContext];
    }];
  }
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
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // 編集なし
  return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  // 編集なし
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // 並び替えなし
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
  /*
   if ([[segue identifier] isEqualToString:@"showItem"]) {
   NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
   CLRStreamCursor *streamCursorObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[segue destinationViewController] setStreamCursor:streamCursorObject];
   }
   */
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSArray *predidateArray = @[@(CLRTypeEnumerationItemNormal), @(CLRTypeEnumerationItemExpanded)];
  int32_t sortId = self.streamCursor.sortId;
  NSPredicate *predidate = [NSPredicate predicateWithFormat:@"type IN %@ AND sortId == %d", predidateArray, sortId];
  [fetchRequest setPredicate:predidate];
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
  NSArray *sortDescriptors = @[sortDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSFetchedResultsController *aFetchedResultsController = [delegate.coreData fetchedResultsControllerWithEntity:CLREntityItemCursor fetchRequest:fetchRequest];
  
  self.fetchedResultsController = aFetchedResultsController;
  aFetchedResultsController.delegate = self;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    CLRLog(@"Unresolved error %@, %@", error, [error userInfo]);
    CLRGAITrackException(error);
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
  // TODO: カスタム表示作成
  CLRItemCursor *itemCursorObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
  CLRItem *itemObject = itemCursorObject.item;
  cell.textLabel.text = itemObject.title;
  cell.detailTextLabel.text = itemObject.content;
}

@end
