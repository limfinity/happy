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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textView.scrollEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.textView.scrollEnabled = YES;
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    [self.textView setContentOffset:CGPointZero animated:NO];
//}

-(NSString *)getTextFromFile {
    NSString *result;
    NSString *fileName = [NSString stringWithFormat:@"%@.md", self.identifier];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) {
        NSArray *pathArray = [fileName componentsSeparatedByString:@"."];
        NSString *bundle;
        if (pathArray.count > 1) {
            bundle = [[NSBundle mainBundle] pathForResource:pathArray[0] ofType:pathArray[1]];
        } else {
            // Guess md extension if no type was given
            bundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@"md"];
        }
        
        // Remove old file if it already exists
        if ([fileManager fileExistsAtPath:path]) {
            if (![fileManager removeItemAtPath:path error:&error]) {
                NSLog(@"Error removing old file %@: %@", fileName, error.description);
                return nil;
            }
        }
        
        if (!bundle) {
            return @"";
        }
        
        if (![fileManager copyItemAtPath:bundle toPath:path error:&error]) {
            NSLog(@"Error getting file %@ from path: %@", fileName, error.description);
            return @"";
        }
    }
    
    result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (result == nil) {
        NSLog(@"Error getting text from file %@", fileName);
        return @"";
    }
    
    return result;
}

// MARK: App lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
