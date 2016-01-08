//
//  HPPYTaskCardViewController.m
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskCardViewController.h"
#import "HPPYTaskDetailViewController.h"

@interface HPPYTaskCardViewController ()

@property (nonatomic, strong) HPPYTask *task;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HPPYTaskCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addRoundedCornersToView:self.categoryImageView];
    [self updateInterface];
}

- (void)addRoundedCornersToView:(UIView *)view {
    NSAssert([view isKindOfClass:[UIView class]], @"Attribute needs to be of type 'UIView' to add rounded corners.");
    
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [self updateInterface];
}

- (void)updateInterface {
    self.titleLabel.text = self.task.title;
    self.categoryImageView.image = [_task categoryImage];
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
