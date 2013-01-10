//
//  CLRStreamList.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRItemList, CLRStream;

@interface CLRStreamList : NSManagedObject

@property (nonatomic) int32_t sortId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) CLRStream *stream;
@property (nonatomic, retain) NSSet *itemList;
@end

@interface CLRStreamList (CoreDataGeneratedAccessors)

- (void)addItemListObject:(CLRItemList *)value;
- (void)removeItemListObject:(CLRItemList *)value;
- (void)addItemList:(NSSet *)values;
- (void)removeItemList:(NSSet *)values;

@end
