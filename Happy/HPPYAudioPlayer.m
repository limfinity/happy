//
//  HPPYAudioPlayer.m
//  Happy
//
//  Created by Peter Pult on 03/04/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface HPPYAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

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
            if (error) {
                NSLog(@"Error creating audio player with file: %@", fileName);
            }
        } else {
            NSLog(@"Error getting path of audio file: %@", fileName);
        }
    }
    return self;
}

// MARK: Public methods
- (void)start {
    if (!_audioPlayer) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.audioPlayer play];
    });
}

- (void)pause {
    if (!_audioPlayer) {
        return;
    }
    [self.audioPlayer pause];
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
}

- (float)progress {
    if (!_audioPlayer) {
        return 0;
    }
    float currentTime = (float)fabs(_audioPlayer.currentTime);
    if (isnan(currentTime)) {
        currentTime = 0;
    }
    NSLog(@"time left: %f", (float)fabs(_audioPlayer.duration) - currentTime);
    float progress = currentTime / (float)fabs(_audioPlayer.duration);
    return progress;
}

- (NSTimeInterval)duration {
    if (!_audioPlayer) {
        return 0;
    }
    return [self.audioPlayer duration];
}

@end
