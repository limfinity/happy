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
#import "ARAnalytics/ARAnalytics.h"

typedef NS_ENUM(NSInteger, HPPYTaskState) {
    HPPYTaskStateAudioPlaying,
    HPPYTaskStateAudioPaused,
    HPPYTaskStateRunning,
    HPPYTaskStateCompletable,
    HPPYTaskStateNotStarted
};

@interface HPPYTaskDetailViewController () {
    BOOL _movedScrollViewToTop;
    HPPYCountDown *_countdown;
    CAShapeLayer *_processAnimationLayer;
    HPPYTaskState _state;
}

@property (strong, nonatomic) HPPYTask *task;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *audioNotice;
@property (weak, nonatomic) IBOutlet UIImageView *audioIcon;
@property (strong, nonatomic) HPPYAudioPlayer *audioPlayer;

@end

@implementation HPPYTaskDetailViewController

// MARK: User interaction
- (IBAction)completeTask:(id)sender {
    if (_state != HPPYTaskStateCompletable) {
        if (_audioPlayer) {
            [self toggleAudioState];
        }
        return;
    }
    [ARAnalytics event:@"Task Completed" withProperties:_task.trackingData];
    HPPYTaskController *taskController = [HPPYTaskController new];
    [taskController completeTask:[HPPYTaskController currentTask]];
    [self performSegueWithIdentifier:@"ShowTaskSuccess" sender:self];
}

// MARK: View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [ARAnalytics pageView:@"Task Detail" withProperties:_task.trackingData];
    
    // Needs to be set to true in storyboard, so font can be changed there, reset to false here.
    self.detailTextView.selectable = NO;
    self.detailTextView.textContainer.lineFragmentPadding = 0;
    self.detailTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 8);
    
    _movedScrollViewToTop = NO;
    _state = HPPYTaskStateNotStarted;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appReturnsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appResignsActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    BOOL isAudio = [_task.type isEqualToString:HPPYTaskTypeAudio];
    if (isAudio) {
        self.audioPlayer = [[HPPYAudioPlayer alloc] initWithTask:_task];
        [self.audioIcon setHidden:NO];
        [self.audioNotice setHidden:NO];
    } else {
        [self.audioIcon setHidden:YES];
        [self.audioNotice setHidden:YES];
    }
    
    [self updateInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self appReturnsActive:nil];
    
    // For audio control begin receiving control events
    if (_audioPlayer) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // For audio control stop receiving control events
    if (_audioPlayer) {
        [_audioPlayer stop];
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
    }
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

- (void)appReturnsActive:(NSNotification *)notification {
    [self updateCompletionButtonUI];
    switch (_state) {
        case HPPYTaskStateNotStarted:
            if (!_audioPlayer) {
                [self startOrResumeProcessingAnimation];
            }
            break;
        case HPPYTaskStateAudioPlaying:
            [self startOrResumeProcessingAnimation];
            break;
        case HPPYTaskStateAudioPaused:
            // Let user resume audio
            break;
        default:
            [self startOrResumeProcessingAnimation];
            break;
    }
}

- (void)appResignsActive:(NSNotification *)notification {
    if (_processAnimationLayer) {
        [_processAnimationLayer removeFromSuperlayer];
        _processAnimationLayer = nil;
    }
    
    if (_countdown) {
        [_countdown stop];
    }
}

// MARK: Audio control
- (void)toggleAudioState {
    if (_audioPlayer.isPlaying) {
        [ARAnalytics event:@"Audio Paused"];
        [_audioPlayer pause];
        _state = HPPYTaskStateAudioPaused;
        [self stopProcessingAnimation];
    } else {
        [_audioPlayer resume];
        [ARAnalytics event:@"Audio Resumed"];
        _state = HPPYTaskStateAudioPlaying;
        [self startOrResumeProcessingAnimation];
    }
    [self updateCompletionButtonUI];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (!_audioPlayer) {
        return;
    }
    
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [_audioPlayer resume];
            _state = HPPYTaskStateAudioPlaying;
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [_audioPlayer pause];
            _state = HPPYTaskStateAudioPaused;
        }
    }
}

// MARK: Interface change
- (void)setTask:(HPPYTask *)task {
    _task = task;
    [HPPYTaskController startTask:_task];
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
    [self updateCompletionButtonUI];
}

- (void)updateCompletionButtonUI {
    NSString *buttonTitle;
    BOOL buttonEnabled;
    UIColor *titleColor;
    switch (_state) {
        case HPPYTaskStateNotStarted:
            if (_audioPlayer) {
                buttonEnabled = YES;
                buttonTitle = NSLocalizedString(@"Play", nil);
            } else {
                buttonEnabled = NO;
                buttonTitle = NSLocalizedString(@"Default Countdown", nil);
            }
            titleColor = [UIColor whiteColor];
            break;
        case HPPYTaskStateAudioPlaying:
            buttonEnabled = YES;
            buttonTitle = NSLocalizedString(@"Pause", nil);
            titleColor = [UIColor whiteColor];
            break;
        case HPPYTaskStateAudioPaused:
            buttonEnabled = YES;
            buttonTitle = NSLocalizedString(@"Play", nil);
            titleColor = [UIColor whiteColor];
            break;
        case HPPYTaskStateRunning:
            // Countdown is displayed
            buttonEnabled = NO;
            titleColor = [UIColor whiteColor];
            break;
        case HPPYTaskStateCompletable:
            buttonEnabled = YES;
            buttonTitle = NSLocalizedString(@"Finish", nil);
            titleColor = self.task.categoryColor;
            break;
    }
    [self.completeButton setTitle:buttonTitle forState:UIControlStateNormal];
    self.completeButton.userInteractionEnabled = buttonEnabled;
    [self.completeButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)activateButton {
    _state = HPPYTaskStateCompletable;
    [self animateButtonActivation];
    [self updateCompletionButtonUI];
}

- (void)startOrResumeProcessingAnimation {
    float progress = _audioPlayer ? _audioPlayer.progress : _task.progress;
    float processingTime = _audioPlayer ? _audioPlayer.duration : [_task.estimatedTime floatValue];
    
    if (_audioPlayer && progress > 0 && _processAnimationLayer) {
        [self resumeProcessingAnimation];
    } else {
        [self startProcessingAnimationWithProgress:progress andProcessingTime:processingTime];
    }
}

- (void)stopProcessingAnimation {
    if (_processAnimationLayer) {
        [self stopTimer];
        CFTimeInterval pausedTime = [_processAnimationLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        _processAnimationLayer.speed = 0.0;
        _processAnimationLayer.timeOffset = pausedTime;
    }
}

- (void)resumeProcessingAnimation {
    if (_processAnimationLayer) {
        CFTimeInterval pausedTime = [_processAnimationLayer timeOffset];
        _processAnimationLayer.speed = 1.0;
        _processAnimationLayer.timeOffset = 0.0;
        _processAnimationLayer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [_processAnimationLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        _processAnimationLayer.beginTime = timeSincePause;
        if (_audioPlayer) {
            NSTimeInterval timeLeft = [_audioPlayer duration] - [_audioPlayer currentTime];
            [self startTimerWithDuration:timeLeft];
        }
        
    }
}

- (void)startTimerWithDuration:(CFTimeInterval)duration {
    _countdown = [[HPPYCountDown alloc] initWithSeconds:duration];
    [_countdown startWithBlock:^(NSString *remainingTime) {
        [self.completeButton setTitle:remainingTime forState:UIControlStateNormal];
    } completion:^{
        [self activateButton];
    }];
}

- (void)stopTimer {
    [_countdown stop];
}

- (void)startProcessingAnimationWithProgress:(float)progress andProcessingTime:(float)processingTime {
    CFTimeInterval duration = processingTime - (progress * processingTime);
    CFTimeInterval minDuration = 1;
    duration = MAX(minDuration, duration);
    
//    NSLog(@"animate with progress: %f, processing time: %f and duration: %f", progress, processingTime, duration);
    
    if (progress <= 1) {
        [self startTimerWithDuration:duration];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.completeButton.bounds cornerRadius:25.0];
    
    _processAnimationLayer = [CAShapeLayer new];
    _processAnimationLayer.fillColor = [UIColor clearColor].CGColor;
    _processAnimationLayer.strokeColor = [UIColor whiteColor].CGColor;
    _processAnimationLayer.lineWidth = 5.0;
    _processAnimationLayer.path = path.CGPath;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(progress);
    animation1.beginTime = 0.0;
    animation1.duration = (progress == 1) ? minDuration : 0.5;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
//    NSLog(@"animation 1 duration: %f", animation1.duration);
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation2.fromValue = @(progress);
    animation2.toValue = @(1.0);
    animation2.beginTime = animation1.duration;
    animation2.duration = duration - animation1.duration;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
//    NSLog(@"animation 2 duration: %f", animation2.duration);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup new];
    animationGroup.animations = @[animation1, animation2];
    animationGroup.duration = animation1.duration + animation2.duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_processAnimationLayer addAnimation:animationGroup forKey:@"processingAnimation"];
    
//    NSLog(@"animation group duration: %f", animationGroup.duration);
    
    [self.completeButton.layer addSublayer:_processAnimationLayer];
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
