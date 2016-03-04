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
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomScrollViewContraint;

@end

@implementation HPPYCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.codeTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [self.codeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSLog(@"didlayout");
}

- (void)unlockHappyWithCode:(NSString *)code {
    if (!_codes) {
        _codes = [HPPY getArrayFromFile:HPPY_CODES_FILE_NAME reloadFromBundle:YES];
    }
    if ([_codes containsObject:code]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hppyUnlocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self handleAppState];
    } else {
        NSLog(@"don't unlock");
        self.scrollView.scrollEnabled = NO;
        [self.codeTextField setText:@""];
        self.scrollView.scrollEnabled = YES;
        [self.loadingIndicatorView stopAnimating];
    }
}

- (void)handleAppState {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate handleAppState];
}

// MARK: Keyboard
- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    CGSize keyboardSize = keyboardFrame.size;
    CGSize size = self.scrollView.contentSize;
    self.bottomScrollViewContraint.constant = keyboardSize.height;
    [self.view layoutIfNeeded];
    CGRect rect = self.codeTextField.frame;
    size.height = rect.origin.y + rect.size.height + 10;
    [self.scrollView setContentSize:size];
    [self scrollToBottom];
}

-(void)scrollToBottom {
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    if (bottomOffset.y > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:bottomOffset animated:YES];
        });
    }
}

// MARK: UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self scrollToBottom];
    // Don't allow more than the defined amount of characters to be entered
    NSMutableString *code = [NSMutableString stringWithString:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if (code.length == HPPY_CODE_LENGTH && ![string isEqualToString:@""]) {
        return NO;
    } else if (code.length == HPPY_CODE_LENGTH - 1 && ![string isEqualToString:@""]) {
        [self.loadingIndicatorView startAnimating];
        [self performSelector:@selector(unlockHappyWithCode:) withObject:[code stringByAppendingString:string] afterDelay:0.5];
        return YES;
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
