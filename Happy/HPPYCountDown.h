//
//  HPPYCountDown.h
//  Happy
//
//  Created by Peter Pult on 21/02/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPPYCountDown : NSObject

- (instancetype)initWithSeconds:(int)seconds;
- (void)startWithBlock:(void (^)(NSString *remainingTime))block completion:(void (^)(void))completionBlock;

@end
