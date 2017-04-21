//
//  JRTMPSession.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFrame.h"
#import "JDemoHeader.h"

typedef NS_ENUM(NSUInteger, JRtmpSessionStatus){
    
    JRtmpSessionStatusNone              = 0,
    JRtmpSessionStatusConnected         = 1,
    
    JRtmpSessionStatusHandshake0        = 2,
    JRtmpSessionStatusHandshake1        = 3,
    JRtmpSessionStatusHandshake2        = 4,
    JRtmpSessionStatusHandshakeComplete = 5,
    
    JRtmpSessionStatusFCPublish         = 6,
    JRtmpSessionStatusReady             = 7,
    JRtmpSessionStatusSessionStarted    = 8,
    
    JRtmpSessionStatusError             = 9,
    JRtmpSessionStatusNotConnected      = 10,
    
    JRtmpSessionStatusSessionStartPlay = 11
};

@class JRTMPSession;
@protocol JRtmpSessionDelegate <NSObject>

- (void)rtmpSession:(JRTMPSession *)rtmpSession didChangeStatus:(JRtmpSessionStatus)rtmpStatus;

- (void)rtmpSession:(JRTMPSession *)rtmpSession receiveVideoData:(uint8_t *)data;

@end

@class JRTMPConfig;
@interface JRTMPSession : NSObject

@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) JRTMPConfig *config;
@property (nonatomic,assign) JCurrentActor currentActor;

@property (nonatomic,weak) id<JRtmpSessionDelegate> delegate;

- (void)connect;

- (void)disConnect;

- (void)sendBuffer:(JFrame *)frame;

@end
