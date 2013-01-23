//
//  CLRItemList.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CLRCursor.h"

@class CLRItem;

@interface CLRItemCursor : CLRCursor

@property (nonatomic) int64_t itemId;
@property (nonatomic) int64_t timestamp;
@property (nonatomic, retain) CLRItem *item;

- (int64_t)setItemIdForString:(NSString *)itemIdString;

@end
