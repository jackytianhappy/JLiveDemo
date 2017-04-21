//
//  JRTMPConfig.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRTMPConfig : NSObject

@property (nonatomic,copy  ) NSString *url;
@property (nonatomic,assign) int32_t  width;
@property (nonatomic,assign) int32_t  height;
@property (nonatomic,assign) double   frameDuration;
@property (nonatomic,assign) int32_t  videoBitrate;
@property (nonatomic,assign) double   audioSampleRate;
@property (nonatomic,assign) BOOL     stereo;//立体声

@end
