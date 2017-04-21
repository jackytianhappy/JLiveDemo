//
//  JSession.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVideoConfig.h"
#import "JVideoSession.h"
#import "JDemoHeader.h"

/**
 *  连接状态
 */
typedef NS_ENUM(NSUInteger, JSessionState) {
    JSessionStateNone,
    JSessionStateConnecting,
    JSessionStateConnected,
    JSessionStateReconnecting,
    JSessionStateEnd,
    JSessionStateError,
};

@class JSession;
@protocol JSessionsDelegate <NSObject>

- (void)sessions:(JSession *)session statusDidChanged:(JSessionState)status;
- (void)sessions:(JSession *)session receiveVideoData:(uint8_t *)data;

@end

@class LLYRtmpConfig;
@interface JSession : NSObject

@property (nonatomic,strong) JVideoSession *videoSession;

@property (nonatomic,weak) id<JSessionsDelegate> delegate;

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) UIView *preView;

@property (nonatomic,assign) JSessionState status;

@property (nonatomic,assign) JCurrentActor currentActor;

+ (instancetype)defultSession;

- (void)startSession;
- (void)endSession;

@end

