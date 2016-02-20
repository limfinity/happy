//
//  HPPYStaticTextViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYStaticTextViewController.h"
#import <TSMarkdownParser/TSMarkdownParser.h>

@interface HPPYStaticTextViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HPPYStaticTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIFont *font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    UIFont *h1Font = [UIFont systemFontOfSize:36.0 weight:UIFontWeightThin];
    TSMarkdownParser *parser = [TSMarkdownParser standardParser];
    [parser setParagraphFont:font];
    [parser setH1Font:h1Font];
    NSAttributedString *markdown = [parser attributedStringFromMarkdown:[self getTextFromFile]];
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

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
