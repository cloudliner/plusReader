//
//  CLRStream.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CLRType.h"

@class CLRStreamList;

@interface CLRStream : CLRType

@property (nonatomic) int32_t sortId;
@property (nonatomic, retain) NSString * streamId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t unreadCount;
@property (nonatomic, retain) CLRStreamList *streamList;

@end
