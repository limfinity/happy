//
//  HPPYAudioPlayer.m
//  Happy
//
//  Created by Peter Pult on 03/04/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HPPYAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, weak) HPPYTask *task;

@end

@implementation HPPYAudioPlayer

- (instancetype)initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        NSArray *pathArray = [fileName componentsSeparatedByString:@"."];
        NSString *path;
        if (pathArray.count > 1) {
            path = [[NSBundle mainBundle] pathForResource:pathArray[0] ofType:pathArray[1]];
        } else {
            // Guess mp3 extension if no type was given
            path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
        }
        if (path) {
            NSError *error = nil;
            NSURL *url = [NSURL fileURLWithPath:path];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [self.audioPlayer prepareToPlay];
            if (error) {
                NSLog(@"Error creating audio player with file: %@", fileName);
            } else {
                [self setupAudioSession];
            }
        } else {
            NSLog(@"Error getting path of audio file: %@", fileName);
        }
    }
    return self;
}

- (instancetype)initWithTask:(HPPYTask *)task {
    NSArray *attachements = task.attachements;
    if (!attachements || attachements.count == 0) {
        NSLog(@"Error attachements for task are empty");
        return nil;
    }
    
    NSString *fileName = (NSString *)attachements.firstObject;
    if (!fileName) {
        NSLog(@"Error getting file name for audio from attachements");
        return nil;
    }
    
    self = [[HPPYAudioPlayer alloc] initWithFileName:fileName];
    
    if (self) {
        self.task = task;
    }
    
    return self;
}

- (void)dealloc {
    NSError *error;
    [_audioSession setActive:NO error:&error];
    if (error) {
        NSLog(@"Error deactivating audio session");
        return;
    }
}

- (void)updateMediaPlayerInformation {
    if (!_task) {
        return;
    }
    
    NSDictionary *mediaPlayingInfo = @{MPMediaItemPropertyTitle: _task.title,
                                       MPMediaItemPropertyArtist: @"Happy",
                                       MPNowPlayingInfoPropertyPlaybackRate: @1};
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = mediaPlayingInfo;
}

- (void)setupAudioSession {
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [_audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [_audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"Error activating audio session");
        return;
    }
    
}

// MARK: Public methods
- (void)start {
    if (!_audioPlayer) {
        return;
    }
    [self updateMediaPlayerInformation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.audioPlayer play];
        self.playing = YES;
    });
}

- (void)pause {
    if (!_audioPlayer) {
        return;
    }
    [self.audioPlayer pause];
    self.playing = NO;
}

- (void)resume {
    if (!_audioPlayer) {
        return;
    }
    [self start];
}

- (void)stop {
    if (!_audioPlayer) {
        return;
    }
    [self.audioPlayer stop];
    self.playing = NO;
}

- (float)progress {
    if (!_audioPlayer) {
        return 0;
    }
    float currentTime = (float)fabs(_audioPlayer.currentTime);
    if (isnan(currentTime)) {
        currentTime = 0;
    }
    float progress = currentTime / (float)fabs(_audioPlayer.duration);
    return progress;
}

- (NSTimeInterval)currentTime {
    if (!_audioPlayer) {
        return 0;
    }
    return  [self.audioPlayer currentTime];
}

- (NSTimeInterval)duration {
    if (!_audioPlayer) {
        return 0;
    }
    return [self.audioPlayer duration];
}

@end
