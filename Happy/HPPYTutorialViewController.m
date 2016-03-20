//
//  HPPYTutorialViewController.m
//  Happy
//
//  Created by Peter Pult on 17/03/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTutorialViewController.h"
#import "HPPYReminderTableViewController.h"

@interface HPPYTutorialViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *contentViewControllers;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@end

@implementation HPPYTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (IBAction)close:(id)sender {
    if (self.pageControl.currentPage != self.pageControl.numberOfPages - 1) {
        [self goToPreviousPage];
        return;
    }
    if (_isOnboarding) {
        [HPPYReminderTableViewController addDefaultNotification];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hppyStartedBefore"];
    }
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
