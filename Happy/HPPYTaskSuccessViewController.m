//
//  HPPYTaskSuccessVIewController.m
//  Happy
//
//  Created by Peter Pult on 20/02/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYTaskSuccessViewController.h"
#import "ARAnalytics/ARAnalytics.h"

@interface HPPYTaskSuccessViewController()

@property (nonatomic, strong) HPPYTask *task;

@end

@implementation HPPYTaskSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ARAnalytics pageView:@"Task Success" withProperties:_task.trackingData];
}

- (void)setTask:(HPPYTask *)task {
    self.task = task;
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
