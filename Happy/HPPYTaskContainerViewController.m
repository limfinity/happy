//
//  ViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskContainerViewController.h"
#import "SWRevealViewController.h"
#import "HPPYTutorialViewController.h"
#import "HPPYTaskController.h"
#import "HPPYTaskCardContainerViewController.h"
#import "ARAnalytics/ARAnalytics.h"

typedef NS_ENUM(NSInteger, HPPYTaskContainerViewState) {
    HPPYTaskContainerViewStateCard,
    HPPYTaskContainerViewStateList
};

@interface HPPYTaskContainerViewController () {
    HPPYTaskContainerViewState _state;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchModeBarButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) UIViewController *currentViewController;

@end

@implementation HPPYTaskContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL showOnboarding = ![[NSUserDefaults standardUserDefaults] boolForKey:@"hppyStartedBefore"];
    if (showOnboarding) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HPPYTutorialViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
        vc.isOnboarding = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
    
    _state = HPPYTaskContainerViewStateCard;
    [self showViewControllerDependingOnState:_state];
    
    [super viewDidLoad];
}

- (IBAction)switchMode:(id)sender {
    switch (_state) {
        case HPPYTaskContainerViewStateCard:
            _state = HPPYTaskContainerViewStateList;
            break;
        case HPPYTaskContainerViewStateList:
            _state = HPPYTaskContainerViewStateCard;
            break;
    }
    [self showViewControllerDependingOnState:_state];
}

- (void)showViewControllerDependingOnState:(HPPYTaskContainerViewState)state {
    UIViewController *viewController;
    
    switch (state) {
        case HPPYTaskContainerViewStateCard:
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskCardContainer"];
            break;
        case HPPYTaskContainerViewStateList:
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskList"];
            break;
    }
    
    [self addViewControllerAsChildViewController:viewController toContainerView:_containerView];
    [self updateBarButtonTitleDependingOnState:state];
    
    if (_currentViewController) {
        [self removeViewControllerAsChildViewController:_currentViewController];
    }
    self.currentViewController = viewController;
}

- (void)updateBarButtonTitleDependingOnState:(HPPYTaskContainerViewState)state {
    switch (state) {
        case HPPYTaskContainerViewStateCard:
            [_switchModeBarButton setImage:[UIImage imageNamed:@"navigationListIcon"]];
            break;
        case HPPYTaskContainerViewStateList:
            [_switchModeBarButton setImage:[UIImage imageNamed:@"navigationSingleIcon"]];
            break;
    }
}

- (void)addViewControllerAsChildViewController:(UIViewController *)viewController toContainerView:(UIView *)containerView {
    // Add Child View Controller
    [self addChildViewController:viewController];
    
    // Add Child View as Subview
    [containerView addSubview:viewController.view];
    
    // Configure Child View
    viewController.view.frame = containerView.bounds;
    viewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // Notify Child View Controller
    [viewController didMoveToParentViewController:self];
}

- (void)removeViewControllerAsChildViewController:(UIViewController *)viewController {
    // Notify Child View Controller
    [viewController willMoveToParentViewController:nil];
    
    // Remove Child View From Superview
    [viewController.view removeFromSuperview];
    
    // Notify Child View Controller
    [viewController removeFromParentViewController];
}

// MARK: Navigation
- (IBAction)canceledTask:(UIStoryboardSegue *)segue {
    [ARAnalytics event:@"Task Canceled" withProperties:[HPPYTaskController currentTask].trackingData];
}

- (IBAction)finishedTask:(UIStoryboardSegue *)segue {
    if ([_currentViewController isKindOfClass:[HPPYTaskCardContainerViewController class]]) {
        HPPYTaskCardContainerViewController *taskViewController = (HPPYTaskCardContainerViewController *)_currentViewController;
        [[taskViewController taskCardViewController] setTask:[HPPYTaskController currentTask]];
    }
}

@end
