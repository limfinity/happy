//
//  AppDelegate.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "AppDelegate.h"
#import "HPPYRightMenuTableViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set language on all devices to German for MVP1
    [[NSUserDefaults standardUserDefaults] setObject:@[@"de"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Update version in settings
    [self updateVersion];
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Reset badge count
        application.applicationIconBadgeNumber = 0;
    }
    
    // Handle root view manually to avoid problems with slide navigation
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    // Show correct view when starting the app
    [self handleAppState];
    
    return YES;
}

- (void)updateVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"hppyVersion"];
}

- (void)handleAppState {
    BOOL unlocked = [[NSUserDefaults standardUserDefaults] boolForKey:@"hppyUnlocked"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (unlocked) {
        // Set up slide menu
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TaskNavigationViewController"];
        [self setupSlideMenu];
    } else {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"CodeViewController"];
    }
}

- (void)setupSlideMenu {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HPPYRightMenuTableViewController *rightMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"RightMenuViewController"];
    [SlideNavigationController sharedInstance].rightMenu = rightMenuViewController;
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [button setImage:[UIImage imageNamed:@"menuBurger"] forState:UIControlStateNormal];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // For now always reset badge count
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertTitle
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Reset badge count
    application.applicationIconBadgeNumber = 0;
}

@end