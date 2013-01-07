//
//  CLRConsole.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRConsole.h"

extern UITextView *plusReader_CLConsole_textView;
extern void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) NS_FORMAT_FUNCTION(4,5);

extern NSString *CLREncodeURL(NSString *plainString);
extern NSString *CLRDecodeURL(NSString *encodedString);

extern unsigned int CLRHexStringToUInt(NSString *hexString);
extern NSString *CLRUIntToHexString(unsigned int number);

void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) {
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

NSString *CLREncodeURL(NSString *plainString) {
  // TODO: 実装が正しいかどうか要確認
  NSString *encodedString = (__bridge NSString *)
  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                          (CFStringRef)plainString,
                                          NULL,
                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                          kCFStringEncodingUTF8);
  return encodedString;
}

NSString *CLRDecodeURL(NSString *encodedString) {
  NSString *decodedString = (__bridge NSString *)
  CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                          (CFStringRef) encodedString,
                                                          CFSTR(""),
                                                          kCFStringEncodingUTF8);
  return decodedString;
}

unsigned int CLRHexStringToUInt(NSString *hexString) {
  NSScanner *scan = [NSScanner scannerWithString:hexString];
  unsigned int number;
  [scan scanHexInt:&number];
  return number;
}

NSString *CLRUIntToHexString(unsigned int number) {
  NSString *hexString = [NSString stringWithFormat:@"%X", number];
  return hexString;
}

// TODO: 実機で単体テストを実行するための暫定対策
@implementation CLRUtils
+(unsigned int)CLRHexStringToUInt:(NSString *)hexString {
  return CLRHexStringToUInt(hexString);
}
+(NSString *)CLRUIntToHexString:(unsigned int)number {
  return CLRUIntToHexString(number);
}
@end
