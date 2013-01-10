//
//  CLRItemList.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRItem, CLRStreamList;

@interface CLRItemList : NSManagedObject

@property (nonatomic) int64_t itemId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) CLRItem *item;
@property (nonatomic, retain) CLRStreamList *streamList;

@end
