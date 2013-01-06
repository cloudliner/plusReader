//
//  CLTag.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLFeed, CLOrdering;

@interface CLTag : NSManagedObject

@property (nonatomic, retain) NSString * idString;
@property (nonatomic) int16_t index;
@property (nonatomic) int32_t sortid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t unreadCount;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic, retain) NSSet *feed;
@property (nonatomic, retain) CLOrdering *ordering;
@end

@interface CLTag (CoreDataGeneratedAccessors)

- (void)addFeedObject:(CLFeed *)value;
- (void)removeFeedObject:(CLFeed *)value;
- (void)addFeed:(NSSet *)values;
- (void)removeFeed:(NSSet *)values;

@end
