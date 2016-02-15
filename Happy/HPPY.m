//
//  HPPY.m
//  Happy
//
//  Created by Peter Pult on 09/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

/* *******************************************
 * NSUserDefaults Variables
 * 
 * hppyName          NSString
 * hppyReminders     NSArray
 * hppyVersion       NSString
 * hppyUnlocked      BOOL
 * hppyCurrentTask   NSData -> HPPYTask
 * hppyStartTimeTask Float
 * AppleLanguages    NSArray
 ******************************************* */

#import "HPPY.h"

@implementation HPPY

+ (NSArray *)getArrayFromFile:(NSString *)fileName reloadFromBundle:(BOOL)reload {
    NSArray *result;
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (reload || ![fileManager fileExistsAtPath: path]) {
        NSArray *pathArray = [fileName componentsSeparatedByString:@"."];
        NSString *bundle;
        if (pathArray.count > 1) {
            bundle = [[NSBundle mainBundle] pathForResource:pathArray[0] ofType:pathArray[1]];
        } else {
            // Guess plist extension if no type was given
            bundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        }
        
        // Remove old file if it already exists
        if ([ fileManager fileExistsAtPath:path]) {
            if (![fileManager removeItemAtPath:path error:&error]) {
                NSLog(@"Error removing old file %@: %@", fileName, error.description);
                return nil;
            }
        }
        
        if (![fileManager copyItemAtPath:bundle toPath:path error:&error]) {
            NSLog(@"Error getting file %@ from path: %@", fileName, error.description);
            return nil;
        }
    }
    
    result = [NSArray arrayWithContentsOfFile:path];
    
    if (result == nil) {
        NSLog(@"Error getting array from file %@", fileName);
        return nil;
    }
    
    return result;
}

@end