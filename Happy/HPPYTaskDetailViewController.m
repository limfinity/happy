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

    // Needs to be set to true in storyboard, so font can be changed there, reset to false here.
    self.detailTextView.selectable = NO;
    
    [self updateInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateButtonBorderWithDuration];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move visible text to top at start.
    [self.detailTextView setContentOffset:CGPointZero];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [self updateInterface];
}

- (void)updateInterface {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"hppyName"];
    if (!name || name.length < 1) {
        self.titleLabel.text = self.task.title;
    } else {
        self.titleLabel.text = [NSString stringWithFormat:self.task.titlePersonalized, name];
    }
    self.detailTextView.text = self.task.body;
    self.backgroundImageView.image = [self.task categoryImage];
}

- (IBAction)cancelTask:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeTask:(id)sender {
}

- (void)animateButtonBorderWithDuration {
    CFTimeInterval startTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"hppyStartTimeTask"];
    CFTimeInterval duration = [self.task.estimatedTime floatValue];
    CFTimeInterval difference;
    float startValue;
    float stopValue = 1.0;
    if (!startTime || startTime == 0) {
        startTime = CACurrentMediaTime();
        difference = 0;
        startValue = 0;
        [[NSUserDefaults standardUserDefaults] setFloat:startTime forKey:@"hppyStartTimeTask"];
    } else {
        difference = CACurrentMediaTime() - startTime;
        startValue = (float)(difference / duration);
        startValue = MIN(1, startValue);
        duration *= (stopValue - startValue);
        if (startValue == 1) {
            [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"hppyStartTimeTask"];
        }
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.completeButton.bounds];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = 5.0;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setDuration:duration];
    [animation setFromValue:(id)@(startValue)];
    [animation setToValue:(id)@(stopValue)];
    [animation setFillMode:kCAFillModeBackwards];
    
    [layer addAnimation:animation forKey:nil];
    
    [self.completeButton.layer addSublayer:layer];
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
