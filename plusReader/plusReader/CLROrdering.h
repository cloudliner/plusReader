//
//  CLROrdering.h
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CLROrdering : NSManagedObject

@property (nonatomic, retain) NSString * idString;
@property (nonatomic, retain) NSString * value;
@property (nonatomic) NSTimeInterval update;

-(int)indexWithSortid:(unsigned int)sortid;

@end
