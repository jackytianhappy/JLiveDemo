//
//  JVideoPackager.m
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import "JVideoPackager.h"
#import "JTypeHeader.h"

@interface JVideoPackager ()
{
    BOOL _hasSendKeyFrame;
}

@end

@implementation JVideoPackager

- (void)dealloc{
    self.delegate = nil;
}

- (instancetype)init{
    
    if(self=[super init]){
        _hasSendKeyFrame = NO;
    }
    return self;
}

- (void)reset{
    _hasSendKeyFrame = NO;
}

- (void)packageKeyFrameSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp{
    
    if (spsData.length <= 0 || ppsData <= 0) {
        return;
    }
    
    if (_hasSendKeyFrame) {
        return;
    }
    
    _hasSendKeyFrame = YES;
    
    const char *sps = spsData.bytes;
    const char *pps = ppsData.bytes;
    NSInteger sps_len = spsData.length;
    NSInteger pps_len = ppsData.length;
    
    NSInteger total = sps_len + pps_len + 16;
    uint8_t *body = (uint8_t *)malloc(total);
    int index = 0;
    
    memset(body,0,total);
    
    body[index++] = 0x17;
    body[index++] = 0x00;//sps_pps
    
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x00;
    
    body[index++] = 0x01;
    body[index++] = sps[1];
    body[index++] = sps[2];
    body[index++] = sps[3];
    body[index++] = 0xff;
    
    /*sps*/
    body[index++]   = 0xe1;
    body[index++] = (sps_len >> 8) & 0xff;
    body[index++] = sps_len & 0xff;
    memcpy(&body[index],sps,sps_len);
    index +=  sps_len;
    
    /*pps*/
    body[index++]   = 0x01;
    body[index++] = (pps_len >> 8) & 0xff;
    body[index++] = (pps_len) & 0xff;
    memcpy(&body[index], pps, pps_len);
    index +=  pps_len;
    
    if ([self.delegate respondsToSelector:@selector(videoPackage:didPacketFrame:)]) {
        NSData *data = [NSData dataWithBytes:body length:index];
        
        JFrame *frame = [[JFrame alloc] init];
        frame.data = data;
        frame.timestamp = 0;//一定是0
        frame.msgLength = (int)data.length;
        frame.msgTypeId = JMSGTypeID_VIDEO;
        frame.msgStreamId = JStreamIDVideo;//video
        frame.isKeyframe = YES;
        [self.delegate videoPackage:self didPacketFrame:frame];
    }
    
}

- (void)packageFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame{
    
    if (!_hasSendKeyFrame) {
        return;
    }
    
    NSInteger i = 0;
    NSInteger total = data.length + 9;
    unsigned char *body = (unsigned char *)malloc(total);
    
    memset(body, 0, total);
    
    if (isKeyFrame) {
        body[i++] = 0x17;//1:I Frame 7:AVC
    }
    else{
        body[i++] = 0x27;//2:P Frame 7:AVC
    }
    body[i++] = 0x01;//AVC NALU 不是psp_pps
    
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = 0x00;//pts - dts
    
    //长度数据
    body[i++] = (data.length >> 24) & 0xff;
    body[i++] = (data.length >> 16) & 0xff;
    body[i++] = (data.length >>  8) & 0xff;
    body[i++] = (data.length ) & 0xff;
    
    memcpy(&body[i], data.bytes, data.length);
    
    if ([self.delegate respondsToSelector:@selector(videoPackage:didPacketFrame:)]) {
        NSData *data = [NSData dataWithBytes:body length:total];
        JFrame *frame = [[JFrame alloc]init];
        frame.data = data;
        frame.timestamp = (int)timestamp;
        frame.msgLength = (int)data.length;
        frame.msgTypeId = JMSGTypeID_VIDEO;
        frame.msgStreamId = JStreamIDVideo;
        frame.isKeyframe = isKeyFrame;
        
        [self.delegate videoPackage:self didPacketFrame:frame];
    }
}

@end

