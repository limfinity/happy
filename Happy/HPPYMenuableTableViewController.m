//
//  HPPYMenuableTableViewController.m
//  Happy
//
//  Created by Peter Pult on 20/02/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYMenuableTableViewController.h"
#import "SWRevealViewController.h"

@interface HPPYMenuableTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation HPPYMenuableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set in initial view controller, afterwards title is set in menu view controller
    UIImage *image = [UIImage imageNamed:@"navigationHeart"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ) {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
