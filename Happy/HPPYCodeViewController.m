//
//  HPPYCodeViewController.m
//  Happy
//
//  Created by Peter Pult on 09/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import "HPPYCodeViewController.h"
#import "HPPY.h"
#import "AppDelegate.h"

#define HPPY_CODE_LENGTH 6
#define HPPY_CODES_FILE_NAME @"hppyCodes.plist"

@interface HPPYCodeViewController () <UITextFieldDelegate> {
    NSArray *_codes;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;

@end

@implementation HPPYCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.unlockButton.enabled = NO;
    self.codeTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTouched)];
    [self.scrollView addGestureRecognizer:gesture];
}

- (IBAction)unlockHappy:(id)sender {
    [self.view endEditing:YES];
    NSString *code = [self.codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!_codes) {
        _codes = [HPPY getArrayFromFile:HPPY_CODES_FILE_NAME reloadFromBundle:YES];
    }
    if ([_codes containsObject:code]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hppyUnlocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate handleAppState];
    } else {
        NSLog(@"don't unlock");
    }
}

// MARK: Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    CGSize keyboardSize = keyboardFrame.size;
    CGSize newScrollViewContentSize = self.scrollView.contentSize;
    newScrollViewContentSize.height += keyboardSize.height;
    [self.scrollView setContentSize:newScrollViewContentSize];
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.scrollView setContentSize:self.contentView.frame.size];
}

// MARK: Gestures
- (void)scrollViewTouched {
    [self.view endEditing:YES];
}

// MARK: UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Don't allow more than the defined amount of characters to be entered
    if (textField.text.length == HPPY_CODE_LENGTH && ![string isEqualToString:@""]) {
        self.unlockButton.enabled = YES;
        return NO;
    } else if (textField.text.length == HPPY_CODE_LENGTH - 1 && ![string isEqualToString:@""]) {
        self.unlockButton.enabled = YES;
    } else {
        self.unlockButton.enabled = NO;
    }
    return YES;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
