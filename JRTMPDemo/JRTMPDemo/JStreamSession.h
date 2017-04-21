//
//  JStreamSession.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSStreamEvent JStreamStatus;
@class JStreamSession;

@protocol JStreamSessionDelegate <NSObject>

- (void)streamSession:(JStreamSession *)session didChangeStatus:(JStreamStatus)streamStatus;

@end

@interface JStreamSession : NSObject

@property (nonatomic,weak) id<JStreamSessionDelegate> delegate;

@property (nonatomic,assign) JStreamStatus streamStatus;

- (void)connectToServer:(NSString *)host port:(UInt32)port;

- (void)disConnect;

- (NSData *)readData;

- (NSInteger)writeData:(NSData *)data;

@end
