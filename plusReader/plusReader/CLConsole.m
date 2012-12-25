//
//  CLConsole.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLConsole.h"

extern UITextView *plusReader_CLConsole_textView;
extern void CLConsole(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

void CLConsole(NSString *format, ...) {
  if (plusReader_CLConsole_textView == nil) {
    return;
  }
  va_list ap;
  va_start(ap,format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
  va_end(ap);
  
  NSLog(@"%@", message);

  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"[HH:mm:ss]"];

  NSMutableString *text = [NSMutableString stringWithCapacity: 0];
  [text appendString:plusReader_CLConsole_textView.text];
  [text appendString:@"\r\n"];
  [text appendString:[dateFormatter stringFromDate:now]];
  [text appendString:@" "];
  [text appendString:message];
  [plusReader_CLConsole_textView setText:text];
}
