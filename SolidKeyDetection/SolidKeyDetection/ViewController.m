//
//  ViewController.m
//  SolidKeyDetection
//
//  Created by sugoqn on 2017/12/11.
//  Copyright © 2017年 sugoqn. All rights reserved.
//

#import "ViewController.h"
#import "SolidKeyDetectionManager.h"
@interface ViewController ()<SKDMuteSwitchDelegate>{
    NSTimer* updateTimer;
}
@property (nonatomic, strong, readwrite) UILabel *Mutelabel;
@property (nonatomic, strong, readwrite) UILabel *volumelabel;
@property (nonatomic, strong, readwrite) UILabel *otherlabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginDetection) userInfo:nil repeats:YES];
    [self.view addSubview:self.Mutelabel];
    self.Mutelabel.frame = CGRectMake(0, 20, self.view.frame.size.width, 40);
    [self.view addSubview:self.volumelabel];
    self.volumelabel.frame = CGRectMake(0, CGRectGetMaxY(self.Mutelabel.frame), self.view.frame.size.width, 40);
    [self.view addSubview:self.otherlabel];
    self.otherlabel.frame = CGRectMake(0, CGRectGetMaxY(self.volumelabel.frame), self.view.frame.size.width, 40);
    [self beginDetection];
}
- (void)beginDetection {
    [[SolidKeyDetectionManager ShareInstance] setDelegate:self];
    [[SolidKeyDetectionManager ShareInstance] detectMuteSwitch];
}
- (UILabel *)Mutelabel {
    if (!_Mutelabel) {
        _Mutelabel = [[UILabel alloc]init];
        _Mutelabel.textColor = [UIColor whiteColor];
        _Mutelabel.font = [UIFont systemFontOfSize:30];
        _Mutelabel.text = @"静音键检测";
        [_Mutelabel sizeToFit];
        _Mutelabel.textAlignment = NSTextAlignmentCenter;
    }
    return _Mutelabel;
}
- (UILabel *)volumelabel {
    if (!_volumelabel) {
        _volumelabel = [[UILabel alloc]init];
        _volumelabel.textColor = [UIColor whiteColor];
        _volumelabel.font = [UIFont systemFontOfSize:30];
        _volumelabel.text = @"音量键检测";
        [_volumelabel sizeToFit];
        _volumelabel.textAlignment = NSTextAlignmentCenter;
    }
    return _volumelabel;
}
- (UILabel *)otherlabel {
    if (!_otherlabel) {
        _otherlabel = [[UILabel alloc]init];
        _otherlabel.textColor = [UIColor whiteColor];
        _otherlabel.font = [UIFont systemFontOfSize:30];
        _otherlabel.text = @"Home+power检测";
        [_otherlabel sizeToFit];
        _otherlabel.textAlignment = NSTextAlignmentCenter;
    }
    return _otherlabel;
}
#pragma mark - SKDMuteSwitchDelegate
- (void)isMuted:(BOOL)muted {
    if (muted) {
        _Mutelabel.text = @"静音";
    }else{
        _Mutelabel.text = @"非静音";
    }
}
- (void)isHomeAndPower {
    _otherlabel.text = @"截屏成功";
}
- (void)isVolumeUp {
    _volumelabel.text = @"音量加";
}
- (void)isVolumeDown {
   _volumelabel.text = @"音量减";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
