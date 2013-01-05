//
//  plusReaderTests.m
//  plusReaderTests
//
//  Created by 大野 廉 on 2012/12/19.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "plusReaderTests.h"

@implementation plusReaderTests

- (void)setUp {
  [super setUp];
  // Set-up code here.
}

- (void)tearDown {
  // Tear-down code here.
  [super tearDown];
}

-(void)testCLHexStringToUInt {
	unsigned int expected = 0xFF00FF00;
	unsigned int result = CLHexStringToUInt(@"FF00FF00");
	STAssertEquals(expected, result, @"");
}

-(void)testCLUIntToHexString {
  NSString *expected = @"FFAAFFAA";
  NSString *result = CLUIntToHexString(0xFFAAFFAA);
  STAssertEqualObjects(expected, result, @"");
}

- (void)testExample {
  // STFail(@"Unit tests are not implemented yet in plusReaderTests");
}

@end
