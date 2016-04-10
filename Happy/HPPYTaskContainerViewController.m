//
//  ViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskContainerViewController.h"
#import "SWRevealViewController.h"
#import "HPPYTaskController.h"
#import "HPPYTaskCardViewController.h"
#import "HPPYCountDown.h"
#import "HPPYTutorialViewController.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYTaskContainerViewController () {
    HPPYTaskController *_taskController;
}

@property (weak, nonatomic) IBOutlet UIView *taskCardView;
@property (weak, nonatomic) HPPYTaskCardViewController *taskCardViewController;

@end

@implementation HPPYTaskContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Call at start to update tasks from file
    [self taskController];
    
    BOOL showOnboarding = ![[NSUserDefaults standardUserDefaults] boolForKey:@"hppyStartedBefore"];
    if (showOnboarding) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HPPYTutorialViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
        vc.isOnboarding = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
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
    
    [ARAnalytics event:@"Task Skipped" withProperties:task.trackingData];
}

// MARK: Storyboard
- (IBAction)canceledTask:(UIStoryboardSegue *)segue {
    [ARAnalytics event:@"Task Canceled" withProperties:[HPPYTaskController currentTask].trackingData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishedTask:(UIStoryboardSegue *)segue {
    [self.taskCardViewController setTask:[HPPYTaskController currentTask]];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTaskCard"]) {
        HPPYTaskCardViewController *vc = segue.destinationViewController;
        self.taskCardViewController = vc;
        [vc setTask:[HPPYTaskController currentTask]];
    }
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
