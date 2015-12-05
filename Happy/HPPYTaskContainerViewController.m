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

@interface HPPYTaskContainerViewController () <SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) HPPYTaskController *taskController;
@property (weak, nonatomic) IBOutlet UIView *taskCardView;

@end

@implementation HPPYTaskContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (HPPYTaskController *)taskController {
    if (!_taskController) {
        self.taskController = [HPPYTaskController new];
    }
    return _taskController;
}

// MARK: Tasks
- (IBAction)skipTask:(id)sender {
    [self.taskController nextTask:[self.taskController currentTask]];
    // TODO: update card
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: SlideNavigationControllerDelegate
-(BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

// MARK: Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTaskCard"]) {
        HPPYTaskCardViewController *vc = segue.destinationViewController;
        self.taskController = self.taskController;
        vc.task = [_taskController currentTask];
    }
}

@end
