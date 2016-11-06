//
//  HPPYTaskCardContainerViewController.m
//  Happy
//
//  Created by Peter Pult on 03/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTaskCardContainerViewController.h"
#import "HPPYTaskController.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYTaskCardContainerViewController () {
    HPPYTaskController *_taskController;
}

@property (weak, nonatomic) IBOutlet UIView *taskCardView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HPPYTaskCardContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Call at start to update tasks from file
    [self taskController];
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
