//
//  HPPYTaskCardContainerViewController.m
//  Happy
//
//  Created by Peter Pult on 03/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTaskCardContainerViewController.h"
#import "HPPYTaskController.h"
#import "HPPYTaskCardViewController.h"
#import "HPPYCountDown.h"
#import "HPPYTutorialViewController.h"
#import "ARAnalytics/ARAnalytics.h"
#import "AppDelegate.h"

@interface HPPYTaskCardContainerViewController () {
    HPPYTaskController *_taskController;
}

@property (weak, nonatomic) IBOutlet UIView *taskCardView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) HPPYTaskCardViewController *taskCardViewController;

@end

@implementation HPPYTaskCardContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Call at start to update tasks from file
    [self taskController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSkipButton];
}

- (HPPYTaskController *)taskController {
    if (!_taskController) {
        _taskController = [HPPYTaskController new];
    }
    return _taskController;
}

// MARK: Tasks
- (IBAction)skipTask:(id)sender {
    HPPYTask *task = [HPPYTaskController currentTask];
    HPPYTask *nextTask = [[self taskController] skipTask:task];
    [self.taskCardViewController setTask:nextTask];
    [self decrementSkipsLeft];
    [self updateSkipButton];
    
    [ARAnalytics event:@"Task Skipped" withProperties:task.trackingData];
}

- (void)updateSkipButton {
    int skipsLeft = [self skipsLeft] - 1;
    if (skipsLeft == 0) {
        self.skipButton.enabled = NO;
        double skipLocked = [[NSUserDefaults standardUserDefaults] doubleForKey:@"hppySkipLocked"];
        if (skipLocked == 0) {
            [[NSUserDefaults standardUserDefaults] setDouble:CACurrentMediaTime() forKey:@"hppySkipLocked"];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:@"hppySkipLocked"];
        self.skipButton.enabled = YES;
    }
    [self.skipButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Skip (x)", nil), skipsLeft] forState:UIControlStateNormal];
}

- (void)decrementSkipsLeft {
    int skipsLeft = [self skipsLeft];
    skipsLeft--;
    [self setSkipsLeft:skipsLeft];
}

- (void)setSkipsLeft:(int)skips {
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)skips forKey:@"hppySkipsLeft"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)skipsLeft {
    int skipsLeft = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"hppySkipsLeft"];
    if (skipsLeft == 0) {
        skipsLeft = 4;
    }
    return skipsLeft;
}

// MARK: Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTaskCard"]) {
        HPPYTaskCardViewController *vc = segue.destinationViewController;
        self.taskCardViewController = vc;
        [vc setTask:[HPPYTaskController currentTask]];
    }
}

// TODO: Reimplement canceling
- (IBAction)canceledTask:(UIStoryboardSegue *)segue {
    [ARAnalytics event:@"Task Canceled" withProperties:[HPPYTaskController currentTask].trackingData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// TODO: Reimplement finishing
- (IBAction)finishedTask:(UIStoryboardSegue *)segue {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate resetSkips];
    [self updateSkipButton];
    [self.taskCardViewController setTask:[HPPYTaskController currentTask]];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
