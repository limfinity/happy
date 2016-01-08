//
//  HPPYStaticTextViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYStaticTextViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import <TSMarkdownParser/TSMarkdownParser.h>

@interface HPPYStaticTextViewController () <SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HPPYStaticTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAttributedString *markdown = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:[self getTextFromFile]];
    [self.textView setAttributedText:markdown];    
}

-(NSString *)getTextFromFile {
    NSString *result;
    NSString *path = [[NSBundle mainBundle] pathForResource:self.identifier ofType:@"md"];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error getting static text for identifier %@ from local file: %@", self.identifier, error.description);
        result = @"";
    } else {
        result = content;
    }
    return result;
}

// MARK: SlideNavigationControllerDelegate
-(BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
