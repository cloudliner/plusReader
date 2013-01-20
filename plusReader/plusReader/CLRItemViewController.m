//
//  CLRItemViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/16.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRItemViewController.h"
#import "CLRAppDelegate.h"
#import "CLRStreamCursor.h"
#import "CLRStream.h"
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
  
  CLRGAITrack();
}

- (void)setStreamCursor:(CLRStreamCursor *)streamCursor {
  if (_streamCursor != streamCursor) {
    _streamCursor = streamCursor;
    
    // 表示を更新
    NSString *streamId = streamCursor.stream.streamId;
    
    CLRAppDelegate *delegate = (CLRAppDelegate *)[[UIApplication sharedApplication] delegate];
    CLRGRRetrieve *grRetrieve = delegate.grRetrieve;
    CLRCoreData *coreData = delegate.coreData;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    // Orderingの取得・更新
    [grRetrieve streamContentsWithId:streamId success:^(NSDictionary *JSON) {
      // TODO: 処理作成
    }];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  #warning Potentially incomplete method implementation.
  // Return the number of sections.
  return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  #warning Incomplete method implementation.
  // Return the number of rows in the section.
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  // Configure the cell...
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
