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
#import "HPPYAudioPlayer.h"

@interface HPPYTaskDetailViewController () {
    BOOL _movedScrollViewToTop;
    HPPYCountDown *_countdown;
}

@property (strong, nonatomic) HPPYTask *task;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (strong, nonatomic) HPPYAudioPlayer *audioPlayer;

@end

@implementation HPPYTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Needs to be set to true in storyboard, so font can be changed there, reset to false here.
    self.detailTextView.selectable = NO;
    self.detailTextView.textContainer.lineFragmentPadding = 0;
    self.detailTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 8);
    
    self.completeButton.enabled = NO;
    _movedScrollViewToTop = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appReturnsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appResignsActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    // TODO: Pause and resume audio when entering and re-entering to and from background
    // TODO: Finish task when audio is done playing pay attention to background behaviour
    // TODO: Don't start playing again when already finished
    
    // TODO: Remove little time differnce between animation and timer. Animation is a little bit longer, at least when disrupted during play time.
    
    BOOL isAudio = [_task.type isEqualToString:HPPYTaskTypeAudio];
    if (isAudio) {
        NSArray *attachements = _task.attachements;
        if (attachements && attachements.count > 0) {
            NSString *fileName = (NSString *)attachements.firstObject;
            if (fileName) {
                self.audioPlayer = [[HPPYAudioPlayer alloc] initWithFileName:fileName];
            } else {
                NSLog(@"Error getting file name for audio from attachements");
            }
        } else {
            NSLog(@"Error attachements for task are empty");
        }
    }
    
    [self updateInterface];
}

- (void)appReturnsActive:(NSNotification *)notification{
    [self processTask];
}

- (void)appResignsActive:(NSNotification *)notification{
    [self.completeButton.layer removeAllAnimations];
    if (_countdown) {
        [_countdown stop];
        _countdown = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self appReturnsActive:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self appResignsActive:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move visible text to top at start.
    if (!_movedScrollViewToTop) {
        [self.detailTextView setContentOffset:CGPointZero];
        _movedScrollViewToTop = YES;
    }
}

- (void)setTask:(HPPYTask *)task {
    _task = task;
    [HPPYTaskController startTask:_task];
    [self updateInterface];
}

- (void)updateInterface {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"hppyName"];
    if (!name || name.length < 1) {
        self.titleLabel.text = self.task.titleUnpersonalized;
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
    float progress = _audioPlayer ? _audioPlayer.progress : _task.progress;
    float processingTime = _audioPlayer ? _audioPlayer.duration : [_task.estimatedTime floatValue];
    [self animateProcessingTimeWithProgress:progress andProcessingTime:processingTime];
    if (_audioPlayer) {
        [_audioPlayer start];
    }
}

- (void)activateButton {
    self.completeButton.titleLabel.text = NSLocalizedString(@"Finish", nil);
    self.completeButton.enabled = YES;
    [self animateButtonActivation];
}

- (void)animateProcessingTimeWithProgress:(float)progress andProcessingTime:(float)processingTime {
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
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation2.fromValue = @(progress);
    animation2.toValue = @(1.0);
    animation2.beginTime = animation1.duration;
    animation2.duration = duration;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup new];
    animationGroup.animations = @[animation1, animation2];
    animationGroup.duration = MAX(1, animation2.duration);
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [layer addAnimation:animationGroup forKey:nil];
    
    [self.completeButton.layer addSublayer:layer];
    
    if (progress <= 1) {
        _countdown = [[HPPYCountDown alloc] initWithSeconds:animationGroup.duration];
        [_countdown startWithBlock:^(NSString *remainingTime) {
            if (progress == 1) {
                [self.completeButton setTitle:NSLocalizedString(@"Default Countdown", nil) forState:UIControlStateDisabled];
            } else {
                [self.completeButton setTitle:remainingTime forState:UIControlStateDisabled];
            }
        } completion:^{
            [self activateButton];
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
