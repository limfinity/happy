//
//  HPPYAudioPlayer.h
//  Happy
//
//  Created by Peter Pult on 03/04/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPPYTask.h"

@interface HPPYAudioPlayer : NSObject

@property (nonatomic, assign, getter=isPlaying) BOOL playing;

- (instancetype)initWithTask:(HPPYTask *)task;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (float)progress;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;

@end
