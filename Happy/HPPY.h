//
//  HPPY.h
//  Happy
//
//  Created by Peter Pult on 09/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HPPY : NSObject

/**
 * Helper method to get an array from a file.
 *
 * @param fileName The filename to search for
 * @param reload Parameter to specify if the file should be reloaded from the bundle
 * @result Array containing content of the file
 */
+ (NSArray *)getArrayFromFile:(NSString *)fileName reloadFromBundle:(BOOL)reload;

/**
 * Helper method to write a given array to a file.
 *
 * @param array The array to save
 * @param fileName The filename to write to
 * @result Bool indicating if writing was successful
 */
+ (BOOL)writeArray:(NSArray *)array toFile:(NSString *)fileName;

/**
 * Helper method to get an image with a solid color.
 *
 * @param color The solid color
 * @param size The size of the image
 * @result Image with given size and color
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end