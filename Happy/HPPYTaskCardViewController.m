//
//  HPPYTaskCardViewController.m
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskCardViewController.h"
#import "HPPYTaskDetailViewController.h"
#import "HPPYTaskController.h"

@interface HPPYTaskCardViewController ()

@property (nonatomic, strong) HPPYTask *task;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastCompletionLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation HPPYTaskCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateInterface];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [self updateInterface];
}

- (void)updateInterface {
    self.titleLabel.text = _task.title;
    self.categoryImageView.image = [_task categoryImage];
    self.backgroundView.backgroundColor = [[_task categoryColor] colorWithAlphaComponent:0.3];
    self.selectButton.backgroundColor = [_task categoryColor];
    self.lastCompletionLabel.textColor = [_task categoryColor];
    
    NSDate *lastCompletionDate = [HPPYTaskController getLastCompletionDateFromTask:_task];
    if (lastCompletionDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d.M.y"]; // Date not localized use `dateFormatFromTemplate:options:locale` to achieve localization
        NSString *dateString = [formatter stringFromDate:lastCompletionDate];
        self.lastCompletionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Completion Date", nil), dateString];
    } else {
        self.lastCompletionLabel.text = @"";
    }
}

- (IBAction)selectTask:(id)sender {
}

// MARK: Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTaskDetail"]) {
        HPPYTaskDetailViewController *vc = segue.destinationViewController;
        [vc setTask:_task];
    }
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
