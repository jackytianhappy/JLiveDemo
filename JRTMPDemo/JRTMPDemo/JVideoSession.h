//
//  JVideoSession.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVideoConfig.h"
#import <AVFoundation/AVFoundation.h>

@class H264JEncoder;
@class JVideoOutputHandler;
@protocol JVideoSessionDelegate <NSObject>

- (void)videoEncode:(H264JEncoder *)encode sps:(NSData *)sps pps:(NSData *)pps time:(uint64_t)time;
- (void)videoEncode:(H264JEncoder *)encode frame:(NSData *)frame time:(uint64_t)time isKeyFrame:(BOOL)isKeyFrame;
- (void)videOutputHandler:(JVideoOutputHandler *)handler didOutputSampleBuffer:(CVPixelBufferRef)pixelBuffer;


@end

@class JVideoOutputHandler;

@interface JVideoSession : NSObject

@property (nonatomic,weak) id<JVideoSessionDelegate> delegate;

@property (nonatomic,strong) UIView *preView;

@property (nonatomic,strong) JVideoConfig *videoConfig;

@property (nonatomic,strong) JVideoOutputHandler *videoOutputHandler;

@property (nonatomic,strong) H264JEncoder *videoEncode;

+ (instancetype)defaultSession;

@end
