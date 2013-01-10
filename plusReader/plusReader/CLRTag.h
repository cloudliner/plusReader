//
//  CLRTag.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CLRStream.h"

@class CLRFeed, CLROrdering;

@interface CLRTag : CLRStream

@property (nonatomic, retain) NSSet *feed;
@property (nonatomic, retain) CLROrdering *ordering;
@end

@interface CLRTag (CoreDataGeneratedAccessors)

- (void)addFeedObject:(CLRFeed *)value;
- (void)removeFeedObject:(CLRFeed *)value;
- (void)addFeed:(NSSet *)values;
- (void)removeFeed:(NSSet *)values;

@end
