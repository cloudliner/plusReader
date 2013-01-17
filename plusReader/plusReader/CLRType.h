//
//  CLRType.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/12.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_OPTIONS(int16_t, CLRTypeEnumerationOptions) {
  CLRTypeEnumerationNone = 0,
//  CLRTypeEnumerationTag = 1 << 0, // 1
//  CLRTypeEnumerationFeed = 1 << 1, // 2
//  CLRTypeEnumerationItem = 1 << 2, // 4
//  CLRTypeEnumerationNormal = 1 << 3, // 8
  CLRTypeEnumerationTagNormal = 9,
  CLRTypeEnumerationFeedNormal = 10,
  CLRTypeEnumerationItemNormal = 12,
//  CLRTypeEnumerationSample = 1 << 4, // 16
  CLRTypeEnumerationTagSample = 17,
  CLRTypeEnumerationFeedSample = 18,
//  CLRTypeEnumerationChild = 1 << 5, // 32
  CLRTypeEnumerationItemExpanded = 36,
  CLRTypeEnumerationChildFeedNormal = 42,
  CLRTypeEnumerationChildFeedSample = 50,
//  CLRTypeEnumerationEmbed = 1 << 6, // 64
  CLRTypeEnumerationTagEmbed = 65,
//  CLRTypeEnumerationHistory = 1 << 7, // 128
  CLRTypeEnumerationTagHistory = 129,
//  CLRTypeEnumerationUpperSeparator = 1 << 8, // 256
  CLRTypeEnumerationUpperSeparatorItem = 260,
//  CLRTypeEnumerationMiddleUSeparator = 1 << 9, // 512
  CLRTypeEnumerationMiddleUSeparatorItem = 516,
//  CLRTypeEnumerationMiddleLSeparator = 1 << 10, // 1024
  CLRTypeEnumerationMiddleLSeparatorItem = 1028,
//  CLRTypeEnumerationLowerSeparator = 1 << 11, // 2048
  CLRTypeEnumerationLowerSeparatorItem = 2052,
};

@interface CLRType : NSManagedObject

@property (nonatomic) int16_t type;
@property (nonatomic) NSTimeInterval update;

@end
