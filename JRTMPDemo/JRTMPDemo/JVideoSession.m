//
//  JVideoSession.m
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import "JVideoSession.h"
#import "JVideoOutputHandler.h"
#import "H264JEncoder.h"

#define NOW (CACurrentMediaTime()*1000)

@interface JVideoSession ()<H264JEncoderDelegate,JVideoOutputDelegate>
{
    NSFileHandle *_fileHandle;
}

@end

@implementation JVideoSession

+ (instancetype)defaultSession{
    
    JVideoSession *session = [[JVideoSession alloc]init];
    return session;
}

- (instancetype)init{
    
    if(self=[super init]){
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"JVideo.h264"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    return self;
}

- (void)dealloc{
    
    NSLog(@"%@ 已销毁",NSStringFromClass([self class]));
    
}

- (void)setVideoConfig:(JVideoConfig *)videoConfig{
    
    _videoConfig = videoConfig;
    
    self.videoOutputHandler.config = videoConfig;
    self.videoEncode.videoConfig = videoConfig;
    
}


- (JVideoOutputHandler *)videoOutputHandler{
    
    if (!_videoOutputHandler) {
        _videoOutputHandler = [[JVideoOutputHandler alloc]init];
        _videoOutputHandler.delegate = self;
    }
    return _videoOutputHandler;
}

- (H264JEncoder *)videoEncode{
    
    if (!_videoEncode) {
        _videoEncode = [[H264JEncoder alloc]init];
        _videoEncode.delegate = self;
    }
    return _videoEncode;
}

#pragma mark - VideoEncodeDelegate
- (void)videoEncode:(H264JEncoder *)encode sps:(NSData *)sps pps:(NSData *)pps time:(uint64_t)time{
    
    NSLog(@"gotSpsPps %d %d", (int)[sps length], (int)[pps length]);
    //    const char bytes[] = "\x00\x00\x00\x01";
    //    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    //    NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
    //    [_fileHandle writeData:byteHeader];
    //    [_fileHandle writeData:sps];
    //    [_fileHandle writeData:byteHeader];
    //    [_fileHandle writeData:pps];
    
    if ([self.delegate respondsToSelector:@selector(videoEncode:sps:pps:time:)]) {
        [self.delegate videoEncode:encode sps:sps pps:pps time:time];
    }
    
}
- (void)videoEncode:(H264JEncoder *)encode frame:(NSData *)frame time:(uint64_t)time isKeyFrame:(BOOL)isKeyFrame{
    
    
    NSLog(@"gotEncodedData %d", (int)[frame length]);
    
    //    const char bytes[] = "\x00\x00\x00\x01";
    //    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    //    NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
    //    [_fileHandle writeData:byteHeader];
    //    [_fileHandle writeData:frame];
    
    if ([self.delegate respondsToSelector:@selector(videoEncode:frame:time:isKeyFrame:)]) {
        [self.delegate videoEncode:encode frame:frame time:time isKeyFrame:isKeyFrame];
    }
}

#pragma mark - VideoOutputDelegate
- (void)videOutputHandler:(JVideoOutputHandler *)handler didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    CVPixelBufferRef pixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    if ([self.delegate respondsToSelector:@selector(videOutputHandler:didOutputSampleBuffer:)]) {
        [self.delegate videOutputHandler:handler didOutputSampleBuffer:pixelBufferRef];
    }
    
    //    [self.videoEncode videoEncodeData:sampleBuffer time:NOW];
    
}

@end
