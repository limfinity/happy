//
//  HPPYRevealViewController.m
//  Happy
//
//  Created by Peter Pult on 20/02/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYRevealViewController.h"

@implementation HPPYRevealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rearViewRevealWidth = CGRectGetWidth(self.view.frame) - 60;
    self.rearViewRevealOverdraw = 60;
    self.frontViewShadowRadius = 1;
    self.frontViewShadowOffset = CGSizeMake(0, 0);
    self.frontViewShadowColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
}

@end
