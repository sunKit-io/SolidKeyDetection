//
//  SolidKeyDetectionManager.m
//  SolidKeyDetection
//
//  Created by sugoqn on 2017/12/11.
//  Copyright © 2017年 sugoqn. All rights reserved.
//

#import "SolidKeyDetectionManager.h"
@implementation SolidKeyDetectionManager
@synthesize delegate;

+ (SolidKeyDetectionManager *)ShareInstance
{
    static SolidKeyDetectionManager  *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[SolidKeyDetectionManager alloc]init];
        }
    });
    return _manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        volume = 0.f;
        
        //获取当前系统音量
        MPVolumeView * slide =[MPVolumeView new];
        UISlider * volumeViewSlider;
        for(UIView * view in [slide subviews]){if([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider =(UISlider*) view;
        }
        }
        volume = [volumeViewSlider value];
        //注册音量监听
        NSError *error;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        // add event handler, for this example, it is `volumeChange:` method
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        
        //注册home + 关机监听
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                          object:nil
                                                           queue:mainQueue
                                                      usingBlock:^(NSNotification *note) {
                                                          // executes after screenshot
                                                          // 此方法只会返回YES
                                                          if ([weakSelf.delegate respondsToSelector:@selector(isHomeAndPower)]) {
                                                              [weakSelf.delegate isHomeAndPower];
                                                          }
                                                      }];
        
        //注册静音键监听
        [self detectMuteSwitch];
    }
    return self;
}
- (void)volumeChanged:(NSNotification *)notification
{
    // service logic here.
    NSDictionary *userInfo = notification.userInfo;
    CGFloat parameter = [[userInfo valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (volume < parameter) {
        if ([self.delegate respondsToSelector:@selector(isVolumeUp)]) {
            [self.delegate isVolumeUp];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(isVolumeDown)]) {
            [self.delegate isVolumeDown];
        }
    }
    volume = parameter;
}
- (void)playbackComplete {
    if ([(id)self.delegate respondsToSelector:@selector(isMuted:)]) {
        // If playback is far less than 100ms then we know the device is muted
        if (soundDuration < 0.010) {
            [delegate isMuted:YES];
        }
        else {
            [delegate isMuted:NO];
        }
    }
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    
}

static void soundCompletionCallback (SystemSoundID mySSID, void* myself) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    [[SolidKeyDetectionManager ShareInstance] playbackComplete];
}

- (void)incrementTimer {
    soundDuration = soundDuration + 0.001;
}

- (void)detectMuteSwitch {
#if TARGET_IPHONE_SIMULATOR
    // The simulator doesn't support detection and can cause a crash so always return muted
    if ([(id)self.delegate respondsToSelector:@selector(isMuted:)]) {
        [self.delegate isMuted:YES];
    }
    return;
#endif
    
#if __IPHONE_5_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    // iOS 5+ doesn't allow mute switch detection using state length detection
    // So we need to play a blank 100ms file and detect the playback length
    soundDuration = 0.0;
    CFURLRef        soundFileURLRef;
    SystemSoundID    soundFileObject;
    
    // Get the main bundle for the app
    CFBundleRef mainBundle;
    mainBundle = CFBundleGetMainBundle();
    
    // Get the URL to the sound file to play
    soundFileURLRef  =    CFBundleCopyResourceURL(
                                                  mainBundle,
                                                  CFSTR ("detection"),
                                                  CFSTR ("aiff"),
                                                  NULL
                                                  );
    
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    
    
    AudioServicesAddSystemSoundCompletion (soundFileObject,NULL,NULL,
                                           soundCompletionCallback,
                                           (__bridge void *) self);
    
    // Start the playback timer
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    // Play the sound
    AudioServicesPlaySystemSound(soundFileObject);
    return;
#else
    // This method doesn't work under iOS 5+
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if(CFStringGetLength(state) > 0) {
        if ([(id)self.delegate respondsToSelector:@selector(isMuted:)]) {
            [self.delegate isMuted:NO];
        }
    }
    if ([(id)self.delegate respondsToSelector:@selector(isMuted:)]) {
        [self.delegate isMuted:YES];
    }
    return;
#endif
}
@end
