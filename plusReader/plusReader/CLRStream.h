//
//  CLRStream.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRStreamList;

@interface CLRStream : NSManagedObject

@property (nonatomic) int32_t sortId;
@property (nonatomic, retain) NSString * streamId;
@property (nonatomic) int16_t index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t unreadCount;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic, retain) CLRStreamList *streamList;

@end
