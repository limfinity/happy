//
//  HPPYTaskCardViewController.m
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskCardViewController.h"

@interface HPPYTaskCardViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HPPYTaskCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateUIWithTask:self.task];
}

- (void)updateUIWithTask:(HPPYTask *)task {
    self.categoryImageView.image = [task categoryImage];
    self.titleLabel.text = task.title;
}

- (IBAction)selectTask:(id)sender {
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
