//
//  JSession.m
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import "JSession.h"
#import "JRTMPConfig.h"
#import "JRTMPSession.h"
#import "JVideoPackager.h"
#import "JVideoOutputHandler.h"
#import "H264JEncoder.h"

#define NOW (CACurrentMediaTime()*1000)


@interface JSession ()<JRtmpSessionDelegate,JVideoPackagerDelegate,JVideoSessionDelegate>
{
    uint64_t _startTime;
    /**
     *  是否可以发送数据
     */
    BOOL     _sendable;
}

@property (nonatomic,strong) JRTMPSession *rtmpSession;
@property (nonatomic,strong) JVideoPackager *videoPackage;

@end


@implementation JSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        _status = JSessionStateNone;
        _sendable = NO;
    }
    return self;
}

- (void)dealloc{
    
    [self endSession];
    
    self.delegate = nil;
}


- (uint64_t)currentTimestamp{
    return NOW - _startTime;
}

+ (instancetype)defultSession{
    
    JSession *sessions = [[JSession alloc]init];
    return sessions;
}

- (JVideoSession *)videoSession{
    
    if (!_videoSession) {
        _videoSession = [JVideoSession defaultSession];
        _videoSession.delegate = self;
        _videoSession.videoConfig = [JVideoConfig defaultConfig];
        
        [self.videoSession.videoOutputHandler startVideoCapture];
    }
    return _videoSession;
}


- (UIView *)preView{
    
    if (!_preView) {
        _preView = [[UIView alloc]init];
        [_preView setValue:self.videoSession.videoOutputHandler.preLayer forKey:@"_layer"];
    }
    return _preView;
}


- (JVideoPackager *)videoPackage{
    
    if (!_videoPackage) {
        _videoPackage = [[JVideoPackager alloc]init];
        _videoPackage.delegate = self;
    }
    return _videoPackage;
}

- (JRTMPSession *)rtmpSession{
    
    if (!_rtmpSession) {
        _rtmpSession = [[JRTMPSession alloc]init];
        _rtmpSession.delegate = self;
        _rtmpSession.currentActor = self.currentActor;
        JRTMPConfig *config = [[JRTMPConfig alloc] init];
        config.url = self.url;
        config.width = self.videoSession.videoConfig.videoSize.width;
        config.height = self.videoSession.videoConfig.videoSize.height;
        config.frameDuration = 1.0 / self.videoSession.videoConfig.fps;
        config.videoBitrate = self.videoSession.videoConfig.bitRate;
        _rtmpSession.config = config;
        //        config.audioSampleRate = self.audioConfig.sampleRate;
        //        config.stereo = self.audioConfig.channels == 2;
    }
    return _rtmpSession;
}


- (void)startSession{
    
    [self.rtmpSession connect];
}

- (void)endSession{
    
    _status = JSessionStateEnd;
    _sendable = NO;
    
    [self.rtmpSession disConnect];
    [self.videoPackage reset];
    
    if ([self.delegate respondsToSelector:@selector(sessions:statusDidChanged:)]) {
        [self.delegate sessions:self statusDidChanged:_status];
    }
}


#pragma mark - rtmp delegate
- (void)rtmpSession:(JRTMPSession *)rtmpSession didChangeStatus:(JRtmpSessionStatus)rtmpStatus{
    
    switch (rtmpStatus) {
        case JRtmpSessionStatusConnected:
        {
            _status = JSessionStateConnecting;
        }
            break;
        case JRtmpSessionStatusSessionStarted:
        {
            _startTime = NOW;
            _sendable = YES;
            _status = JSessionStateConnected;
        }
            
            break;
        case JRtmpSessionStatusNotConnected:
        {
            _status = JSessionStateEnd;
            [self endSession];
        }
            break;
        case JRtmpSessionStatusError:
        {
            _status = JSessionStateError;
            [self endSession];
        }
            break;
            
        case JRtmpSessionStatusSessionStartPlay:
        {
            
            
        }
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(sessions:statusDidChanged:)]) {
        [self.delegate sessions:self statusDidChanged:_status];
    }
}

- (void)videOutputHandler:(JVideoOutputHandler *)handler didOutputSampleBuffer:(CVPixelBufferRef)pixelBuffer{
    
    if (!_sendable) {
        return;
    }
    
    [self.videoSession.videoEncode encodeVideo:pixelBuffer time:self.currentTimestamp];
}

- (void)videoEncode:(H264JEncoder *)encode sps:(NSData *)sps pps:(NSData *)pps time:(uint64_t)time{
    
    if (!_sendable) {
        return;
    }
    [self.videoPackage packageKeyFrameSps:sps pps:pps timestamp:time];
}
- (void)videoEncode:(H264JEncoder *)encode frame:(NSData *)frame time:(uint64_t)time isKeyFrame:(BOOL)isKeyFrame{
    
    if (!_sendable) {
        return;
    }
    [self.videoPackage packageFrame:frame timestamp:time isKeyFrame:isKeyFrame];
}

- (void)videoPackage:(JVideoPackager *)package didPacketFrame:(JFrame *)frame{
    
    if (!_sendable) {
        return;
    }
    if (_rtmpSession) {
        [_rtmpSession sendBuffer:frame];
    }
}

- (void)rtmpSession:(JRTMPSession *)rtmpSession receiveVideoData:(uint8_t *)data{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessions:receiveVideoData:)]) {
        [self.delegate sessions:self receiveVideoData:data];
    }
}
@end

