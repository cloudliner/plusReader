//
//  CLConsole.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLConsole.h"

extern UITextView *plusReader_CLConsole_textView;
extern void CLConsole(const char *function, int line, const char *fileName, NSString *format, ...) NS_FORMAT_FUNCTION(4,5);

void CLConsole(const char *function, int line, const char *fileName, NSString *format, ...) {
  va_list ap;
  va_start(ap, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
  va_end(ap);
  
  // 関数名、コード行の追加
  NSMutableString *text = [NSMutableString stringWithCapacity: 0];
  [text appendFormat:@"%s (%s:%d) ", function, fileName, line];
  [text appendString:message];
  
  // ログ出力
  NSLog(@"%@", text);
  
  if (plusReader_CLConsole_textView == nil) {
    return;
  }
  
  // コンソール出力
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"[HH:mm:ss]"];
  [text insertString:[dateFormatter stringFromDate:now] atIndex:0];
  [text insertString:@"\r\n" atIndex:0];
  [text insertString:plusReader_CLConsole_textView.text atIndex:0];
  [plusReader_CLConsole_textView setText:text];
}
