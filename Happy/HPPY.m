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
 * hppyStartedBefore BOOL
 * hppyName          NSString
 * hppyReminders     NSArray
 * hppyAllowTracking BOOL
 * hppyVersion       NSString
 * hppySkipsLeft     NSInteger
 * hppySkipLocked    Double
 * hppyCurrentTask   NSData -> HPPYTask
 * AppleLanguages    NSArray
 ******************************************* */

#import "HPPY.h"
#import "ARAnalytics/ARAnalytics.h"

@implementation HPPY
+ (BOOL)writeArray:(NSArray *)array toFile:(NSString *)fileName {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // Remove old file if it already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        if (![fileManager removeItemAtPath:path error:&error]) {
            ARLog(@"Error removing old file %@: %@", fileName, error.description);
            return NO;
        }
    }
    
    return [array writeToFile:path atomically:YES];
}

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
        if ([fileManager fileExistsAtPath:path]) {
            if (![fileManager removeItemAtPath:path error:&error]) {
                ARLog(@"Error removing old file %@: %@", fileName, error.description);
                return nil;
            }
        }
        
        if (!bundle) {
            return @[];
        }
        
        if (![fileManager copyItemAtPath:bundle toPath:path error:&error]) {
            ARLog(@"Error getting file %@ from path: %@", fileName, error.description);
            return nil;
        }
    }
    
    result = [NSArray arrayWithContentsOfFile:path];
    
    if (result == nil) {
        ARLog(@"Error getting array from file %@", fileName);
        return nil;
    }
    
    return result;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
