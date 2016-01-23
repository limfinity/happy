//
//  HPPYSettingsTableViewController.m
//  Happy
//
//  Created by Peter Pult on 13/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYSettingsTableViewController.h"
#import "HPPYReminderTableViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import "HPPYHeaderTableViewCell.h"
#import "HPPYTextInputTableViewCell.h"
#import "HPPYReminderTableViewCell.h"

@interface HPPYSettingsTableViewController () <UITextFieldDelegate, SlideNavigationControllerDelegate> {
    NSString *_name;
    NSMutableArray *_reminders;
}

@end

@implementation HPPYSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Settings", nil);
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
    NSMutableArray *reminders = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"hppyReminders"]];
    _reminders = reminders ? reminders : [NSMutableArray new];
    
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
    cell.textLabel.text = stringFromDate;
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
    return 35;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// MARK: UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 100) {
        NSString *username = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (username.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"hppyName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Use tableview behaviour for deselecting the row
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
            [self tableView:self.tableView willDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            return YES;
        }
        
        return NO;
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

// MARK: SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
