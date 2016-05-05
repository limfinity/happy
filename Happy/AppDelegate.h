//
//  AppDelegate.h
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)handleAppState;
- (void)resetSkips;

@end

