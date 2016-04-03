//
//  HPPYAudioPlayer.h
//  Happy
//
//  Created by Peter Pult on 03/04/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPPYAudioPlayer : NSObject

- (instancetype)initWithFileName:(NSString *)fileName;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (float)progress;
- (NSTimeInterval)duration;

@end
