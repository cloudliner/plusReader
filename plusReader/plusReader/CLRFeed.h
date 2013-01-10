//
//  CLRFeed.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CLRStream.h"

@class CLRTag;

@interface CLRFeed : CLRStream

@property (nonatomic, retain) NSString * htmlUrl;
@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSSet *tag;
@end

@interface CLRFeed (CoreDataGeneratedAccessors)

- (void)addTagObject:(CLRTag *)value;
- (void)removeTagObject:(CLRTag *)value;
- (void)addTag:(NSSet *)values;
- (void)removeTag:(NSSet *)values;

@end
