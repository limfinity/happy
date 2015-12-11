//
//  HPPYTaskDetailViewController.m
//  Happy
//
//  Created by Peter Pult on 11/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskDetailViewController.h"

@interface HPPYTaskDetailViewController ()

@property (strong, nonatomic) HPPYTask *task;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@end

@implementation HPPYTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateInterface];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [self updateInterface];
}

- (void)updateInterface {
    self.titleLabel.text = self.task.titlePersonalized;
    self.detailTextView.text = self.task.body;
    self.backgroundImageView.image = [self.task categoryImage];
}

- (IBAction)cancelTask:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeTask:(id)sender {
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
