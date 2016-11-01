//
//  HPPYReminderTableViewController.m
//  Happy
//
//  Created by Peter Pult on 08/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "HPPYReminderTableViewController.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYReminderTableViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation HPPYReminderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title;
    if (self.reminder) {
        title = NSLocalizedString(@"Edit Reminder", nil);
        [self.datePicker setDate:self.reminder];
    } else {
        title = NSLocalizedString(@"Add Reminder", nil);
    }
    [self setTitle:title];
    
    [ARAnalytics pageView:title];
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
// MARK: Reminder
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
    [HPPYReminderTableViewController addLocalNotification:reminder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeReminder {
    NSDate *reminder = self.reminder;
    if (reminder) {
        [self removeLocalNotification:reminder];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: Notifications
+ (void)addDefaultNotification {
    NSDateComponents *time = [[NSDateComponents alloc] init];
    [time setHour:19];
    [time setMinute:0];
    NSDate *reminder = [[NSCalendar currentCalendar] dateFromComponents:time];
    [HPPYReminderTableViewController addLocalNotification:reminder];
}

+ (void)addLocalNotification:(NSDate *)reminder {
    [ARAnalytics event:@"Reminder Added" withProperties:@{@"Date": reminder}];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = reminder;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
        notification.alertTitle = NSLocalizedString(@"Friendly Reminder", nil);
    }
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
            [ARAnalytics event:@"Reminder Removed" withProperties:@{@"Date": reminder}];
            [app cancelLocalNotification:notification];
            return;
        }
    }
    [ARAnalytics event:@"Failed Reminder Removed" withProperties:@{@"Date": reminder}];
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
