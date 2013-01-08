//
//  CLROrdering.m
//  plusReader
//
//  Created by 大野 廉 on 2013/01/06.
//  Copyright (c) 2013年 cloudliner.jp. All rights reserved.
//

#import "CLROrdering.h"

const int kSORTID_LENGTH = 8;

@interface CLROrdering() {
  unsigned int *_sortidArray;
  int _arraySize;
}
@end

@implementation CLROrdering

@dynamic idString;
@dynamic value;
@dynamic update;

-(void)setValue:(NSString *)value {
  [self willChangeValueForKey:@"value"];
  [self setPrimitiveValue:value forKey:@"value"];
  [self didChangeValueForKey:@"value"];
  
  if (value == nil || value.length == 0) {
    return;
  }
  int arraySize = value.length/kSORTID_LENGTH;
  unsigned int *sortidArray = (unsigned int *)malloc(sizeof(unsigned int) * arraySize);
  // TODO: mallocした配列の初期化は必要？
  for (int i = 0; i < arraySize; i ++) {
    NSString *sortidString = [value substringWithRange:NSMakeRange(i * kSORTID_LENGTH, kSORTID_LENGTH)];
    unsigned int sortid = CLRHexStringToUInt(sortidString);
    sortidArray[i] = sortid;
  }
  // TODO: メモリを解放する際の順序はこれでいいのか？
  unsigned int *arrayToDelete = _sortidArray;
  _sortidArray = sortidArray;
  _arraySize = arraySize;
  if (arrayToDelete != NULL) {
    free(arrayToDelete);
  }
}

-(int)indexWithSortid:(unsigned int)sortid {
  // TODO: スレッドセーフじゃない？
  if (_sortidArray != NULL) {
    for (int i = 0; i < _arraySize; i ++) {
      if (sortid == _sortidArray[i]) {
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
