//
//  HPPYTutorialViewController.m
//  Happy
//
//  Created by Peter Pult on 17/03/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTutorialViewController.h"
#import "HPPYReminderTableViewController.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYTutorialViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *contentViewControllers;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehaviour;

@end

@implementation HPPYTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ARAnalytics pageView:@"Tutorial" withProperties:@{@"Is Onboarding": _isOnboarding ? @"Yes" : @"No"}];
    
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    UIViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial1ViewController"];
    UIViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial2ViewController"];
    UIViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial3ViewController"];
    UIViewController *vc4 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial4ViewController"];
    
    _contentViewControllers = @[vc1, vc2, vc3, vc4];
    
    [self updatePageControlToIndex:0];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37);
    [self.pageViewController setViewControllers:@[_contentViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.view bringSubviewToFront:self.pageControl];
    [self.view bringSubviewToFront:self.closeButton];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bouncePageViewController:)];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupPageViewControllerViewAnimatorProperties];
}

- (void)setupPageViewControllerViewAnimatorProperties {
    NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIView *view = self.pageViewController.viewControllers.firstObject.view;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[view]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -35, 0, 0)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[view]];
    self.gravityBehaviour.gravityDirection = CGVectorMake(1.0f, 0.0f);
    [self.animator addBehavior:self.gravityBehaviour];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
    itemBehaviour.elasticity = 0.6f;
    [self.animator addBehavior:itemBehaviour];
}

- (void)bouncePageViewController:(UITapGestureRecognizer *)recognizer {
    // Only bounce on first page
    if (self.pageControl.currentPage == 0) {
        self.pushBehavior.pushDirection = CGVectorMake(-35.0f, 0.0f);
        self.pushBehavior.active = YES;
    }
}

- (IBAction)close:(id)sender {
    if (self.pageControl.currentPage != self.pageControl.numberOfPages - 1) {
        [ARAnalytics event:@"Tapped Next" withProperties:@{@"Current Page": @(self.pageControl.currentPage)}];
        [self goToPreviousPage];
        return;
    }
    if (_isOnboarding) {
        [HPPYReminderTableViewController addDefaultNotification];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hppyStartedBefore"];
    }
    [ARAnalytics event:@"Tapped Close"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goToPreviousPage {
    NSInteger currentIndex = ((UIViewController *)self.pageViewController.viewControllers.firstObject).view.tag;
    
    // Don't do anything if we're already at the first page
    if (currentIndex >= self.pageControl.numberOfPages - 1) {
        return;
    }
    
    // Instead get the view controller of the previous page
    UIViewController *vc = [self viewControllerAtIndex:++currentIndex];
    NSArray *initialViewControllers = [NSArray arrayWithObject:vc];
    
    // Do the setViewControllers: again but this time use direction animation:
    [self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self updatePageControlToIndex:currentIndex];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    UIViewController *vc =  _contentViewControllers[index];
    vc.view.tag = index;
    return vc;
}

- (void)updatePageControlToIndex:(NSInteger)index {
    if (index >= self.pageControl.numberOfPages - 1) {
        if (_isOnboarding) {
            [self.closeButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        } else {
            [self.closeButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
        }
    } else {
        [self.closeButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    }
    self.pageControl.currentPage = index;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        NSInteger currentIndex = ((UIViewController *)pageViewController.viewControllers.firstObject).view.tag;
        [self updatePageControlToIndex:currentIndex];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [_contentViewControllers indexOfObject:viewController];
    
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    
    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [_contentViewControllers indexOfObject:viewController];

    if (index == NSNotFound || ++index >= _contentViewControllers.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    NSInteger tutorials = _contentViewControllers.count;
    self.pageControl.numberOfPages = tutorials;
    return tutorials;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
