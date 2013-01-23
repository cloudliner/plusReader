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
extern int64_t CLRLongLongForHexString(NSString *hexString);

id<GAITracker> CLRGAI_tracker = nil;
extern void CLRGAIInit();
extern BOOL CLRGAITrackWithFunction(const char *function);
extern BOOL CLRGAITrackErrorWithFunction(const char *function, NSString *format, ...);
extern BOOL CLRGAITrackExceptionWithFunction(const char *function, id exception);

void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) {
  va_list ap;
  va_start(ap, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
  va_end(ap);
  
  NSMutableString *text = [NSMutableString string];
  // スレッド名の追加
  if([NSThread isMainThread]) {
    [text appendString:@"[main]"];
  } else {
    NSThread *currentThread = [NSThread currentThread];
    [text appendFormat:@"[%@]", currentThread];
  }
  // 関数名、コード行の追加
  [text appendFormat:@"%s (%s:%d)\n  ", function, fileName, line];
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

int32_t CLRIntForHexString(NSString *hexString) {
  NSScanner *scan = [NSScanner scannerWithString:hexString];
  uint32_t number;
  [scan scanHexInt:&number];
  return (int32_t)number;
}

NSString *CLRHexStringForInt(int32_t number) {
  uint32_t uint = (uint32_t)number;
  NSString *hexString = [NSString stringWithFormat:@"%X", uint];
  return hexString;
}

int64_t CLRLongLongForHexString(NSString *hexString) {
  NSScanner *scan = [NSScanner scannerWithString:hexString];
  uint64_t number;
  [scan scanHexLongLong:&number];
  return (int64_t)number;
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

BOOL CLRGAITrackWithFunction(const char *function) {
  const char *position_start = strstr(function, "[");
  const char *position_middle = strstr(function, " ");
  const char *position_end  = strstr(function, "]");
  if (position_start != NULL && position_middle != NULL && position_end != NULL) {
    intptr_t classNameSize = position_middle - position_start - 1;
    intptr_t methodNameSize = position_end - position_middle - 1;
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
      return [CLRGAI_tracker trackView:className];
    } else {
      return [CLRGAI_tracker trackEventWithCategory:className
                                         withAction:methodName
                                          withLabel:nil
                                          withValue:nil];      
    }
  }
  return NO;
}

BOOL CLRGAITrackErrorWithFunction(const char *function, NSString *format, ...) {
  va_list ap;
  va_start(ap, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
  va_end(ap);
  
  return [CLRGAI_tracker trackException:NO withDescription:@"%s %@", function, message];
}

BOOL CLRGAITrackExceptionWithFunction(const char *function, id exception) {
  if ([exception isKindOfClass:[NSException class]]) {
    NSException *nsexception = (NSException *)exception;
    return [CLRGAI_tracker trackException:NO
                          withDescription:@"%s NSException:name=%@,reason=%@,userInfo=%@", function, nsexception.name, nsexception.reason, nsexception.userInfo];
  } else if ([exception isKindOfClass:[NSError class]]) {
    NSError *nserror = (NSError *)exception;
    return [CLRGAI_tracker trackException:NO
                          withDescription:@"%s NSError:domain=%@,code=%d,description=%@", function, nserror.domain, nserror.code, nserror.description];
  } else {
    return [CLRGAI_tracker trackException:NO
                           withDescription:@"%s NSObject:%@", function, exception];

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
