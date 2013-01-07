//
//  CLROrdering.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLROrdering.h"

const int kSORTID_LENGTH = 8;

@implementation CLROrdering

@dynamic idString;
@dynamic value;
@dynamic update;

-(NSArray *)sortidArray {
  // value を unsigned int の配列に変換したものを返す
  [self willAccessValueForKey:@"value"];
  NSString *value = [self primitiveValueForKey:@"value"];
  [self didAccessValueForKey:@"value"];
  if (value == nil || value.length == 0) {
    return nil;
  }
  int arraySize = value.length/kSORTID_LENGTH;
  NSMutableArray *rtnArray = [NSMutableArray arrayWithCapacity:arraySize];
  for (int i = 0; i < arraySize; i ++) {
    NSString *sortidString = [value substringWithRange:NSMakeRange(i * kSORTID_LENGTH, kSORTID_LENGTH)];
    NSNumber *sortid = [NSNumber numberWithUnsignedInt:CLRHexStringToUInt(sortidString)];
    [rtnArray addObject:(sortid)];
  }
  return rtnArray;
}

-(int)indexWithSortid:(unsigned int)sortid {
  NSArray *sortidArray = [self sortidArray];
  for (int i = 0; i < sortidArray.count; i ++) {
    unsigned int currentSortid = [[sortidArray objectAtIndex:i] unsignedIntValue];
    if (currentSortid == sortid) {
      return i;
    }
  }
  return -1;
}

@end
