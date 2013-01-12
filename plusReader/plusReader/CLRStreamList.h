//
//  CLRStreamList.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/11.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CLRList.h"

@class CLRStream;

@interface CLRStreamList : CLRList

@property (nonatomic) int32_t index;
@property (nonatomic, retain) CLRStream *stream;

@end
