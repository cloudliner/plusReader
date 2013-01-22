//
//  CLRUtils.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __file__ (strrchr(__FILE__, '/') + 1)
#define CLRLog(format, ...) CLRConsole(__PRETTY_FUNCTION__, __LINE__, __file__, format, ##__VA_ARGS__)

void CLRConsole(const char *function, int line, const char *fileName, NSString *format, ...) NS_FORMAT_FUNCTION(4,5);
void CLRConsoleClear();
NSString *CLRConsoleText();

NSString *CLREncodeURL(NSString *plainString);
NSString *CLRDecodeURL(NSString *encodedString);

int32_t CLRIntForHexString(NSString *hexString);
NSString *CLRHexStringForInt(int32_t number);

#define CLRGAITrack() CLRGAITrackWithFunction(__PRETTY_FUNCTION__)
#define CLRGAITrackError(format, ...) CLRGAITrackErrorWithFunction(__PRETTY_FUNCTION__, format, ##__VA_ARGS__)
#define CLRGAITrackException(exception) CLRGAITrackExceptionWithFunction(__PRETTY_FUNCTION__, exception)

void CLRGAIInit();
BOOL CLRGAITrackWithFunction(const char *function);
BOOL CLRGAITrackErrorWithFunction(const char *function, NSString *format, ...);
BOOL CLRGAITrackExceptionWithFunction(const char *function, id exception);

// TODO: 実機で単体テストを実行するための暫定対策
@interface CLRUtils : NSObject
+ (int)CLRIntForHexString:(NSString *)hexString;
+ (NSString *)CLRHexStringForInt:(int)number;
@end
