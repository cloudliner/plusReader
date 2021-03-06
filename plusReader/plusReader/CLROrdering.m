//
//  CLROrdering.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLROrdering.h"
#import "CLRTag.h"

const int kSORTID_LENGTH = 8;

@interface CLROrdering() {
  int32_t *_sortidArray;
  int _arraySize;
}
@end

@implementation CLROrdering

@dynamic streamId;
@dynamic update;
@dynamic value;
@dynamic tag;

-(void)setValue:(NSString *)value {
  [self willChangeValueForKey:@"value"];
  [self setPrimitiveValue:value forKey:@"value"];
  [self didChangeValueForKey:@"value"];
  
  if (value == nil || value.length == 0) {
    return;
  }
  int arraySize = value.length/kSORTID_LENGTH;
  int32_t *sortidArray = (int32_t *)calloc(arraySize, sizeof(int32_t));
  for (int i = 0; i < arraySize; i ++) {
    NSString *sortidString = [value substringWithRange:NSMakeRange(i * kSORTID_LENGTH, kSORTID_LENGTH)];
    int32_t sortid = CLRIntForHexString(sortidString);
    sortidArray[i] = sortid;
  }
  int32_t *arrayToDelete = _sortidArray;
  _sortidArray = sortidArray;
  _arraySize = arraySize;
  if (arrayToDelete != NULL) {
    free(arrayToDelete);
  }
}

-(int)indexWithSortId:(int32_t)sortId {
  // TODO: スレッドセーフじゃない？
  if (_sortidArray != NULL) {
    for (int i = 0; i < _arraySize; i ++) {
      if (sortId == _sortidArray[i]) {
        return i;
      }
    }
  }
  return -1;
}

-(void)dealloc {
  if (_sortidArray != NULL) {
    free(_sortidArray);
  }
}

@end
