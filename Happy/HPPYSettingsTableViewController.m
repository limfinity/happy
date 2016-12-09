//
//  HPPYSettingsTableViewController.m
//  Happy
//
//  Created by Peter Pult on 13/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYSettingsTableViewController.h"
#import "HPPYReminderTableViewController.h"
#import "HPPYHeaderTableViewCell.h"
#import "HPPYTextInputTableViewCell.h"
#import "HPPYReminderTableViewCell.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYSettingsTableViewController () <UITextFieldDelegate> {
    NSString *_name;
    NSMutableArray *_reminders;
}

@end

@implementation HPPYSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ARAnalytics pageView:@"Settings"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSettings];
    [self.tableView reloadData];
}

- (void)updateSettings {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"hppyName"];
    _name = name ? name : @"";
    [self updateReminders];
}

- (void)updateReminders {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *reminders = [NSMutableArray new];
    for (UILocalNotification *notification in notifications) {
        [reminders addObject:notification.fireDate];
    }
    _reminders = reminders;
    
    // Sort reminders only using the time
    if (_reminders.count > 1) {
        NSArray *sortedReminders = [_reminders sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2) {
            NSDateComponents *comps1 = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                                       fromDate:d1];
            NSDateComponents *comps2 = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                                       fromDate:d2];
            NSDate *date1 = [[NSCalendar currentCalendar] dateFromComponents:comps1];
            NSDate *date2 = [[NSCalendar currentCalendar] dateFromComponents:comps2];
            return [date1 compare:date2];
        }];
        _reminders = [sortedReminders mutableCopy];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return _reminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HPPYTextInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textInput" forIndexPath:indexPath];
        cell.textField.text = _name;
        cell.textField.placeholder = NSLocalizedString(@"Jane Doe", nil);
        cell.textField.tag = 100;
        cell.textField.delegate = self;
        return cell;
    }
    
    HPPYReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addReminder" forIndexPath:indexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *reminder = _reminders[indexPath.row];
    NSString *stringFromDate = [formatter stringFromDate:reminder];
    cell.timeLabel.text = stringFromDate;
    cell.textLabel.text = @"";
    cell.reminder = reminder;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HPPYTextInputTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField setUserInteractionEnabled:YES];
        [cell.textField becomeFirstResponder];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HPPYTextInputTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField setUserInteractionEnabled:NO];
        [cell.textField resignFirstResponder];
    }
    return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Name", nil);
    }
    
    return NSLocalizedString(@"Reminders", nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *identifier;
    if (section == 0) {
        identifier = @"headerNameSection";
    } else {
        identifier = @"headerReminderSection";
    }
    HPPYHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        [NSException raise:@"Header view is nil" format:@"No cell with matching cell identifier could be loaded from your storyboard."];
    }
    cell.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // Remove spacing after section
    return 0.000001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 104;
    }
    
    return 150;
}

// MARK: UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 100) {
        NSString *username = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [ARAnalytics event:@"Name Updated" withProperties:@{@"Is Empty": username.length > 0 ? @"No" : @"Yes"}];
        
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"hppyName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Use tableview behaviour for deselecting the row
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
        [self tableView:self.tableView willDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    return YES;
}

// MARK: Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"ShowReminderFormEdit"]) {
         HPPYReminderTableViewController *vc = (HPPYReminderTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
         vc.reminder = [((HPPYReminderTableViewCell *)sender).reminder copy];
     }
 }

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
