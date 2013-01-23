//
//  CLRItemList.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLRItemCursor.h"
#import "CLRItem.h"


@implementation CLRItemCursor

@dynamic itemId;
@dynamic timestamp;
@dynamic item;

- (int64_t)setItemIdForString:(NSString *)itemIdString {
  NSString *kITEMID_PREFIX = @"tag:google.com,2005:reader/item/";
  NSRange lastSlash = [itemIdString rangeOfString:@"/" options:NSBackwardsSearch];
  NSString *hexString = [itemIdString substringFromIndex:(lastSlash.location + 1)];
  CLRLog(@"hexULongLongString=%@", hexString);
  int64_t itemId = CLRLongLongForHexString(hexString);
  
  [self willChangeValueForKey:@"itemId"];
  [self setPrimitiveValue:@(itemId) forKey:@"itemId"];
  [self didChangeValueForKey:@"itemId"];
  
  return (int64_t)itemId;
}
@end
