//
//  CLConsole.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef plusReader_CLConsole_h
#define plusReader_CLConsole_h

#define __file__ (strrchr(__FILE__, '/') + 1)
#define CLLog(format, ...) CLConsole(__PRETTY_FUNCTION__, __LINE__, __file__, format, ##__VA_ARGS__)

UITextView *plusReader_CLConsole_textView;
void CLConsole(const char *function, int line, const char *fileName, NSString *format, ...) NS_FORMAT_FUNCTION(4,5);

NSString *CLEncodeURL(NSString *plainString);
NSString *CLDecodeURL(NSString *encodedString);

unsigned int CLHexStringToUInt(NSString *hexString);
NSString *CLUIntToHexString(unsigned int number);

#endif

// TODO: 実機で単体テストを実行するための暫定対策
@interface CLUtils : NSObject
+(unsigned int)CLHexStringToUInt:(NSString *)hexString;
+(NSString *)CLUIntToHexString:(unsigned int)number;
@end