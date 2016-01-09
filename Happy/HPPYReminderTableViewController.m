//
//  HPPYReminderTableViewController.m
//  Happy
//
//  Created by Peter Pult on 08/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "HPPYReminderTableViewController.h"

@interface HPPYReminderTableViewController () {
    NSMutableSet *_reminders;
}

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation HPPYReminderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _reminders = [self getReminders];
    
    NSString *title;
    if (self.reminder) {
        title = NSLocalizedString(@"Edit Reminder", nil);
    } else {
        title = NSLocalizedString(@"Add Reminder", nil);
    }
    [self setTitle:title];
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
// MARK: Reminder
- (NSMutableSet *)getReminders {
    NSArray *reminders = [[NSUserDefaults standardUserDefaults] arrayForKey:@"hppyReminders"];
    return reminders ? [NSMutableSet setWithArray:reminders] : [NSMutableSet new];
}

- (void)saveReminders {
    NSArray *reminderArray = [_reminders allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:reminderArray forKey:@"hppyReminders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)updateReminder:(id)sender {
    NSDate *reminder = self.datePicker.date;
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSCalendarUnitHour | NSCalendarUnitMinute
                              fromDate:reminder];
    NSInteger minutes = [time minute];
    int fiveTimes = (int)minutes / 5;
    minutes = fiveTimes * 5.0;
    [time setMinute: minutes];
    [time setSecond:0];
    reminder = [[NSCalendar currentCalendar] dateFromComponents:time];
    [self removeReminder];
    [_reminders addObject:reminder];
    [self addLocalNotification:reminder];
    [self saveReminders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeReminder {
    if (self.reminder) {
        [_reminders removeObject:self.reminder];
        [self removeLocalNotification:self.reminder];
    }
}


// MARK: Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.reminder) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deleteReminder" forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Delete Reminder", nil);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeReminder];
    [self saveReminders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: Notifications
- (void)addLocalNotification:(NSDate *)reminder {
    // TODO: Move check to onboarding
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = reminder;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertTitle = NSLocalizedString(@"Friendly Reminder", nil);
    notification.alertBody = NSLocalizedString(@"Push Reminder Body 1", nil);
    notification.repeatInterval = NSCalendarUnitDay;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // Always show max. 1 as badge count
    notification.applicationIconBadgeNumber = 1;
    
    UIApplication *app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:notification];
}

- (void)removeLocalNotification:(NSDate *)reminder {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if ([notification.fireDate isEqualToDate:reminder]) {
            [app cancelLocalNotification:notification];
        }
    }
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
