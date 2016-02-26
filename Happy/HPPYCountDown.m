//
//  HPPYCountDown.m
//  Happy
//
//  Created by Peter Pult on 21/02/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYCountDown.h"


@interface HPPYCountDown() {
    NSTimer *_timer;
    int _currMinute;
    int _currSeconds;
}

@end


@implementation HPPYCountDown

- (instancetype)initWithSeconds:(int)seconds {
    self = [super init];
    if (self) {
        if (seconds <= 0) {
            _currSeconds = _currMinute = 0;
        } else {
            _currSeconds = seconds % 60;
            _currMinute = seconds / 60;
        }
    }
    return self;
}

- (void)startWithBlock:(void (^)(NSString *remainingTime))block completion:(void (^)(void))completionBlock {
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:@[block, completionBlock] repeats:YES];
    _timer = [NSTimer timerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerFired:)
                                   userInfo:@[block, completionBlock]
                                    repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

// MARK: Private methods
- (void)timerFired:(NSTimer *)timer {
    NSArray *blocks;
    if ([timer.userInfo isKindOfClass:NSClassFromString(@"NSArray")]) {
        blocks = timer.userInfo;
    } else {
        return;
    }
    
    void* (^block)(NSString*);
    if ([blocks[0] isKindOfClass:NSClassFromString(@"NSBlock")]) {
        block = blocks[0];
    } else {
        return;
    }
    
    void* (^completionBlock)(void);
    if ([blocks[1] isKindOfClass:NSClassFromString(@"NSBlock")]) {
        completionBlock = blocks[1];
    }
    
    if((_currMinute > 0 || _currSeconds >= 0) && _currMinute >= 0) {
        if(_currSeconds==0) {
            _currMinute -= 1;
            _currSeconds = 59;
        } else if (_currSeconds > 0) {
            _currSeconds -= 1;
        }
        if(_currMinute > -1) {
            NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", _currMinute, _currSeconds];
            block(timeString);
            if (_currMinute == 0 && _currSeconds == 0) {
                completionBlock();
            }
        }
    } else {
        [_timer invalidate];
    }
}

@end
