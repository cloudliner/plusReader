//
//  CLRItemStatus.h
//  plusReader
//
//  Created by 大野 廉 on 2013/02/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLRItemCursor;

@interface CLRItemStatus : NSManagedObject

@property (nonatomic) BOOL fresh;
@property (nonatomic) BOOL read;
@property (nonatomic) BOOL starred;
@property (nonatomic) NSTimeInterval update;
@property (nonatomic, retain) CLRItemCursor *itemCursor;

@end
