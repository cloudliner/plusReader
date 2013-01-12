//
//  CLRType.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/12.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CLRType : NSManagedObject

@property (nonatomic) int16_t type;
@property (nonatomic) NSTimeInterval update;

@end
