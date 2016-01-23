//
//  ViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskContainerViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import "HPPYTaskController.h"
#import "HPPYTaskCardViewController.h"

@interface HPPYTaskContainerViewController () <SlideNavigationControllerDelegate> {
    HPPYTaskController *_taskController;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIView *taskCardView;
@property (weak, nonatomic) HPPYTaskCardViewController *taskCardViewController;

@end

@implementation HPPYTaskContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (HPPYTaskController *)taskController {
    if (!_taskController) {
        _taskController = [HPPYTaskController new];
    }
    return _taskController;
}

// MARK: Tasks
- (IBAction)skipTask:(id)sender {
    [[self taskController] nextTask:[[self taskController] currentTask]];
    [self.taskCardViewController setTask:[[self taskController] currentTask]];
    
    // Reset timer for started task
    [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"hppyStartTimeTask"];
}

// MARK: SlideNavigationControllerDelegate
-(BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

// MARK: Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTaskCard"]) {
        HPPYTaskCardViewController *vc = segue.destinationViewController;
        self.taskCardViewController = vc;
        [vc setTask:[[self taskController] currentTask]];
    }
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
