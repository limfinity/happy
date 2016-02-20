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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@end

@implementation HPPYTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Needs to be set to true in storyboard, so font can be changed there, reset to false here.
    self.detailTextView.selectable = NO;
    self.detailTextView.textContainer.lineFragmentPadding = 0;
    self.detailTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 8);
    
    self.completeButton.enabled = NO;
    
    [self updateInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self processTask];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move visible text to top at start.
    [self.detailTextView setContentOffset:CGPointZero];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [_task start];
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
    self.view.backgroundColor = self.task.categoryColor;
    [self.completeButton setTitleColor:self.task.categoryColor forState:UIControlStateNormal];
}

- (IBAction)cancelTask:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeTask:(id)sender {
    NSLog(@"Wants to complete task");
    [self performSegueWithIdentifier:@"ShowTaskSuccess" sender:self];
}

- (void)processTask {
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [self activateButton];
        }];
        [self animateProcessingTime];
    } [CATransaction commit];
}

- (void)activateButton {
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
        }];
        self.completeButton.enabled = YES;
        [self animateButtonActivation];
    } [CATransaction commit];
}

- (void)animateProcessingTime {
    float progress = [_task progress];
    float processingTime = [_task.estimatedTime floatValue];
    CFTimeInterval duration = processingTime - (progress * processingTime);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.completeButton.bounds cornerRadius:25.0];
    
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 5.0;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(progress);
    animation1.beginTime = 0.0;
    animation1.duration = progress * 2;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation2.fromValue = @(progress);
    animation2.toValue = @(1.0);
    animation2.beginTime = animation1.duration;
    animation2.duration = duration;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup new];
    animationGroup.animations = @[animation1, animation2];
    animationGroup.duration = animation1.duration + animation2.duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:animationGroup forKey:nil];
    
    [self.completeButton.layer addSublayer:layer];
}

- (void)animateButtonActivation {
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 0.0;
    layer.frame = self.completeButton.bounds;
    layer.cornerRadius = 25.0;
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    fillAnimation.fromValue = @(0);
    fillAnimation.toValue = @(50);
    fillAnimation.beginTime = 0;
    fillAnimation.duration = 0.7;
    fillAnimation.fillMode = kCAFillModeForwards;
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:fillAnimation forKey:nil];
    
    [self.completeButton.layer insertSublayer:layer atIndex:0];
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
