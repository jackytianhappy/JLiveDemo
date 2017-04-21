//
//  JVideoPackager.h
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFrame.h"

@class JVideoPackager;
@protocol JVideoPackagerDelegate <NSObject>

- (void)videoPackage:(JVideoPackager *)package didPacketFrame:(JFrame *)frame;

@end



@interface JVideoPackager : NSObject

@property (nonatomic,weak) id<JVideoPackagerDelegate> delegate;

- (void)reset;

- (void)packageKeyFrameSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp;

- (void)packageFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame;

@end
