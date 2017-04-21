//
//  JVideoOutputHandler.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "JVideoConfig.h"

@class JVideoOutputHandler;

@protocol JVideoOutputDelegate <NSObject>

- (void)videOutputHandler:(JVideoOutputHandler *)handler didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface JVideoOutputHandler : NSObject

@property (nonatomic,weak) id<JVideoOutputDelegate> delegate;

//预览
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preLayer;

//配置
@property (nonatomic,strong) JVideoConfig *config;

//开始录制
- (void)startVideoCapture;

//结束录制
- (void)stopVideoCapture;

//设置缩放系数
- (void)adjustVideoScaleAndCropFactor:(CGFloat)scale;
//调整画面朝向
- (void)adjustVideoOrientation:(AVCaptureVideoOrientation)orientation;

@end

