//
//  CLRFeed.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRTag;

@interface CLRFeed : NSManagedObject

@property (nonatomic, retain) NSString * htmlUrl;
@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSString * idString;
@property (nonatomic) int16_t index;
@property (nonatomic) int32_t sortid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t unreadCount;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic, retain) NSSet *tag;
@end

@interface CLRFeed (CoreDataGeneratedAccessors)

- (void)addTagObject:(CLRTag *)value;
- (void)removeTagObject:(CLRTag *)value;
- (void)addTag:(NSSet *)values;
- (void)removeTag:(NSSet *)values;

@end
