//
//  AppDelegate.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "AppDelegate.h"
#import "HPPYLeftMenuTableViewController.h"
#import "ARAnalytics/ARAnalytics.h"

@import HockeySDK;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"d58816ba9e5b41c6b38eeacd4bf86c54"];
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"94087a5528db42e592fcad4093678c57"];
#endif
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];
    
    // Set up tracking
    [ARAnalytics setupWithAnalytics:@{
      ARGoogleAnalyticsID : @"UA-76220642-1",
      ARMixpanelToken : @"a93872e0566a689e37e755be7102f41d"
    }];

    // Customize appearances
    [self customizeNavigationBarAppearance];
    
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
    
    // Make background white to light up horizontal flip animations
    self.window.backgroundColor = [UIColor whiteColor];

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
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    } else {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"CodeViewController"];
    }
}

- (void)customizeNavigationBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"navigationShadow"]];
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