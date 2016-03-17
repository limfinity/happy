//
//  HPPYTutorialViewController.m
//  Happy
//
//  Created by Peter Pult on 17/03/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTutorialViewController.h"

@interface HPPYTutorialViewController () <UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *contentViewControllers;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@end

@implementation HPPYTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial1ViewController"];
    UIViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial2ViewController"];
    
    _contentViewControllers = @[vc1, vc2];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    [self.pageViewController setViewControllers:@[_contentViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view insertSubview:_pageViewController.view atIndex:0];
    [self.pageViewController didMoveToParentViewController:self];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return _contentViewControllers[index];
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
    return _contentViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
