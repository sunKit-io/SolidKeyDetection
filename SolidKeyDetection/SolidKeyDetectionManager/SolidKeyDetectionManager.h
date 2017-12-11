//
//  SolidKeyDetectionManager.h
//  SolidKeyDetection
//
//  Created by sugoqn on 2017/12/11.
//  Copyright © 2017年 sugoqn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
@protocol SKDMuteSwitchDelegate
@required
/**
 是否为静音
 
 @param muted 静音开关
 */
- (void)isMuted:(BOOL)muted;
/**
 音量是否增加
 */
- (void)isVolumeUp;
/**
 音量是否减少
 */
- (void)isVolumeDown;
/**
 是否为组合件 home + power 按下
 */
- (void)isHomeAndPower;
@end

@interface SolidKeyDetectionManager : NSObject {
@private
    NSObject<SKDMuteSwitchDelegate> *delegate;
    float soundDuration;
    NSTimer *playbackTimer;
    CGFloat volume;
}
/**
 监听
 */
@property (readwrite, retain) NSObject<SKDMuteSwitchDelegate> *delegate;
/**
单利模式
@return 返回当前对象,对象为单利模式
*/
+ (SolidKeyDetectionManager *)ShareInstance;
/**
 注册当前控制器进行数据监听

 @param sender 控制器
 */
- (void)registerManagerWith:(id)sender;

- (void)detectMuteSwitch;
@end
