//
//  CLRUtils.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRUtils.h"

NSMutableString *CLRConsoleBuffer = nil;
extern void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) NS_FORMAT_FUNCTION(4,5);
extern void CLRConsoleClear();
extern NSString *CLRConsoleText();

extern NSString *CLREncodeURL(NSString *plainString);
extern NSString *CLRDecodeURL(NSString *encodedString);

extern int CLRIntForHexString(NSString *hexString);
extern NSString *CLRHexStringForInt(int number);

id<GAITracker> CLRGAI_tracker = nil;
extern void CLRGAIInit();
extern void CLRGAITrackWithFunction(const char *function);

void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) {
  va_list ap;
  va_start(ap, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
  va_end(ap);
  
  // 関数名、コード行の追加
  NSMutableString *text = [NSMutableString string];
  [text appendFormat:@"%s (%s:%d) ", function, fileName, line];
  [text appendString:message];
  
  // ログ出力
  NSLog(@"%@", text);
  
  const int kBUFFER_SIZE = (512 * 256);
  const int kCLEAR_SIZE = (512 * 32);
  
  if (CLRConsoleBuffer == nil) {
#ifdef DEBUG
    CLRConsoleBuffer = [NSMutableString stringWithCapacity:(kBUFFER_SIZE)];
#else
    return;
#endif
  }
  
  if (kBUFFER_SIZE < [CLRConsoleBuffer length]) {
    // コンソールクリア
    NSRange clearRange = [CLRConsoleBuffer lineRangeForRange:NSMakeRange(0, kCLEAR_SIZE)];
    [CLRConsoleBuffer deleteCharactersInRange:clearRange];
  }
  
  // コンソール出力
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"[HH:mm:ss]"];
  [text insertString:[dateFormatter stringFromDate:now] atIndex:0];
  [text insertString:@"\n" atIndex:0];
  [CLRConsoleBuffer appendString:text];
}

void CLRConsoleClear() {
  [CLRConsoleBuffer setString:@""];
}

NSString *CLRConsoleText() {
  if (CLRConsoleBuffer == nil) {
    return @"";
  }
  return CLRConsoleBuffer;
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

int CLRIntForHexString(NSString *hexString) {
  NSScanner *scan = [NSScanner scannerWithString:hexString];
  unsigned int number;
  [scan scanHexInt:&number];
  return (int)number;
}

NSString *CLRHexStringForInt(int number) {
  unsigned int uint = (unsigned int)number;
  NSString *hexString = [NSString stringWithFormat:@"%X", uint];
  return hexString;
}

void CLRGAIInit() {
  if (CLRGAI_tracker != nil) {
    return;
  }
#ifdef DEBUG
  [GAI sharedInstance].debug = NO;
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  [GAI sharedInstance].dispatchInterval = 30;
#else
  [GAI sharedInstance].debug = NO;
  [GAI sharedInstance].trackUncaughtExceptions = NO;
  [GAI sharedInstance].dispatchInterval = 180;
#endif
  
  CLRGAI_tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-11599435-3"];
  CLRGAI_tracker.useHttps = YES;
}

void CLRGAITrackWithFunction(const char *function) {
  const char *position_start = strstr(function, "[");
  const char *position_middle = strstr(function, " ");
  const char *position_end  = strstr(function, "]");
  if (position_start != NULL && position_middle != NULL && position_end != NULL) {
    int classNameSize = position_middle - position_start - 1;
    int methodNameSize = position_end - position_middle - 1;
    char classNameBuffer[classNameSize + 1];
    char methodNameBuffer[methodNameSize + 1];
    // メモリを初期化しないと不正な文字が出力される
    memset(classNameBuffer, NULL, sizeof(classNameBuffer));
    memset(methodNameBuffer, NULL, sizeof(methodNameBuffer));
    strncpy(classNameBuffer, (position_start + 1), classNameSize);
    strncpy(methodNameBuffer, (position_middle + 1), methodNameSize);
    NSString *className = [NSString stringWithCString:classNameBuffer encoding:NSASCIIStringEncoding];
    NSString *methodName = [NSString stringWithCString:methodNameBuffer encoding:NSASCIIStringEncoding];
    
    if ([methodName isEqualToString:@"viewDidLoad"]) {
      [CLRGAI_tracker trackView:className];
    } else {
      [CLRGAI_tracker trackEventWithCategory:className
                                  withAction:methodName
                                   withLabel:nil
                                   withValue:nil];      
    }
  }
}

// TODO: 実機で単体テストを実行するための暫定対策
@implementation CLRUtils
+ (int)CLRIntForHexString:(NSString *)hexString {
  return CLRIntForHexString(hexString);
}
+ (NSString *)CLRHexStringForInt:(int)number {
  return CLRHexStringForInt(number);
}
@end
