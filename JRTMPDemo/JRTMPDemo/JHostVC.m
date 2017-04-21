//
//  JHostVC.m
//  JRTMPDemo
//
//  Created by Jacky on 2017/4/9.
//  Copyright © 2017年 jacky. All rights reserved.
//

#import "JHostVC.h"
#import "JVideoSession.h"
#import "JVideoConfig.h"
#import "JVideoOutputHandler.h"
#import "JSession.h"

#define RTMP_URL  @"rtmp://192.168.99.202/myapp/mystream"

@interface JHostVC ()<UIGestureRecognizerDelegate,JSessionsDelegate>{
    
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
    AVCaptureVideoOrientation currentOrientation;
    
}
@property (nonatomic,strong) JSession *session;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;
@property (strong, nonatomic) IBOutlet UIButton *pushLiveBtn;

@end

@implementation JHostVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setSessiones];
    
    [self addPinchRecognizer];
    beginGestureScale = effectiveScale = 1.0f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setSessiones{
    
    currentOrientation = AVCaptureVideoOrientationPortrait;
    
    self.session = [JSession defultSession];
    self.session.currentActor = JDirectorActor;
    self.session.delegate = self;
    self.session.url = RTMP_URL;
    
    self.session.preView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.session.preView atIndex:0];
    
}


- (void)sessions:(JSession *)session statusDidChanged:(JSessionState)status{
    switch (status) {
        case JSessionStateConnecting:
        {
            self.statusLbl
            .backgroundColor = [UIColor orangeColor];
            self.statusLbl.text = @"连接中...";
        }
            break;
        case JSessionStateConnected:
        {
            self.statusLbl.backgroundColor = [UIColor greenColor];
            self.statusLbl.text = @"已连接";
            [self.pushLiveBtn setTitle:@"结束推流" forState:UIControlStateNormal];
        }
            break;
        default:
        {
            self.statusLbl.backgroundColor = [UIColor redColor];
            self.statusLbl.text = @"未连接";
            [self.pushLiveBtn setTitle:@"开始推流" forState:UIControlStateNormal];
        }
            break;
    }
}



//添加缩放手势，调节焦距 ---
- (void)addPinchRecognizer{
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchScreen:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)pinchScreen:(UIPinchGestureRecognizer *)recognizer{
    
    effectiveScale = beginGestureScale * recognizer.scale;
    if (effectiveScale < 1.0)
        effectiveScale = 1.0;
    if (effectiveScale > 10.0)
        effectiveScale = 10.0;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.view.layer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];
    
    [self.session.videoSession.videoOutputHandler adjustVideoScaleAndCropFactor:effectiveScale];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}

- (IBAction)videoOrientation:(id)sender {
    
    //    if (currentOrientation == AVCaptureVideoOrientationPortrait) {
    //        [self.session.videoSession.videoOutputHandler adjustVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    //        currentOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    //    }
    //    else{
    //        [self.session.videoSession.videoOutputHandler adjustVideoOrientation:AVCaptureVideoOrientationPortrait];
    //        currentOrientation = AVCaptureVideoOrientationPortrait;
    //    }
    
    switch (self.session.status) {
        case JSessionStateConnecting:
        case JSessionStateConnected:
        {
            [self.session endSession];
        }
            break;
            
        default:
        {
            [self.session startSession];
        }
            break;
    }
    
}
@end
