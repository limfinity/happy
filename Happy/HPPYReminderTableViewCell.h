//
//  HPPYReminderTableViewCell.h
//  Happy
//
//  Created by Peter Pult on 08/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPPYReminderTableViewCell : UITableViewCell

@property (nonatomic, weak) NSDate *reminder;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
