//
//  CLRItem.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRItemList;

@interface CLRItem : NSManagedObject

@property (nonatomic, retain) NSString * href;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic) int64_t timestamp;
@property (nonatomic) int64_t itemId;
@property (nonatomic, retain) NSString * streamId;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic, retain) NSSet *itemList;
@end

@interface CLRItem (CoreDataGeneratedAccessors)

- (void)addItemListObject:(CLRItemList *)value;
- (void)removeItemListObject:(CLRItemList *)value;
- (void)addItemList:(NSSet *)values;
- (void)removeItemList:(NSSet *)values;

@end
