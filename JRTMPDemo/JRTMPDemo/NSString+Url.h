//
//  NSString+Url.h
//  LLYRtmpDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>

//解析推流地址
@interface NSString (Url)

@property(readonly) NSString *scheme;
@property(readonly) NSString *host;
@property(readonly) NSString *app;
@property(readonly) NSString *playPath;
@property(readonly) UInt32    port;

@end
