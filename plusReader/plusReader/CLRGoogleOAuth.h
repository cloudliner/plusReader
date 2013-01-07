//
//  CLRGoogleOAuth.h
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#ifndef plusReader_CLGoogleOAuth_h
#define plusReader_CLGoogleOAuth_h

#if TARGET_IPHONE_SIMULATOR
  // シミュレーター
  #define GOOGLE_OAUTH2_CLIENT_ID @"156833183371-ud1v2ht9smqh4c7mpoq7hen1m7pl8oh2.apps.googleusercontent.com"
  #define GOOGLE_OAUTH2_CLIENT_SECRET @"Lo70WbLFQdSuWz_fQR4NEQWp"
#else
  // 実機
  // TODO: 認証が失敗する原因を要確認
  // #define GOOGLE_OAUTH2_CLIENT_ID @"156833183371.apps.googleusercontent.com"
  #define GOOGLE_OAUTH2_CLIENT_ID @"156833183371-ud1v2ht9smqh4c7mpoq7hen1m7pl8oh2.apps.googleusercontent.com"
  // #define GOOGLE_OAUTH2_CLIENT_SECRET @"i-_sryy6QgPL1Hg9yyTWzW9N"
  #define GOOGLE_OAUTH2_CLIENT_SECRET @"Lo70WbLFQdSuWz_fQR4NEQWp"
#endif

#define GOOGLE_OAUTH2_REDIRECT_URIS @"urn:ietf:wg:oauth:2.0:oob"
#define GOOGLE_OAUTH2_SCOPE CLREncodeURL(@"https://www.google.com/reader/api")
#define GOOGLE_OAUTH2_STORE_NAME @"google_oauth"

#endif
