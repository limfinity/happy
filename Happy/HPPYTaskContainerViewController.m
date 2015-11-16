//
//  ViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskContainerViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>

@interface HPPYTaskContainerViewController () <SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation HPPYTaskContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: SlideNavigationControllerDelegate
-(BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

@end
