//
//  HPPYTaskDetailViewController.m
//  Happy
//
//  Created by Peter Pult on 11/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskDetailViewController.h"
#import "HPPYTaskController.h"
#import "HPPYCountDown.h"

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self processTask];
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [HPPYTaskController startTask:_task];
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

- (IBAction)completeTask:(id)sender {
    HPPYTaskController *taskController = [HPPYTaskController new];
    [taskController completeTask:[HPPYTaskController currentTask]];
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
        self.completeButton.titleLabel.text = NSLocalizedString(@"Finish", nil);
        self.completeButton.enabled = YES;
        [self animateButtonActivation];
    } [CATransaction commit];
}

- (void)animateProcessingTime {
    float progress = [_task progress];
    float processingTime = [_task.estimatedTime floatValue];
    CFTimeInterval duration = processingTime - (progress * processingTime);
    duration = MAX(duration, 1);
    
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
    
    if (progress < 1) {
        HPPYCountDown *cd = [[HPPYCountDown alloc] initWithSeconds:animationGroup.duration];
        [cd startWithBlock:^(NSString *remainingTime) {
                [self.completeButton setTitle:remainingTime forState:UIControlStateDisabled];
        } completion:^{
            NSLog(@"timer finished");
        }];
    }
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
