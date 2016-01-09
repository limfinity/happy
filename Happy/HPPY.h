//
//  HPPY.h
//  Happy
//
//  Created by Peter Pult on 09/01/16.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPPY : NSObject

/**
 * Helper method to get an array from a file.
 *
 * @param fileName The filename to search for
 * @param reload Parameter to specify if the file should be reloaded from the bundle
 * @result Array containing content of the file
 */
+ (NSArray *)getArrayFromFile:(NSString *)fileName reloadFromBundle:(BOOL)reload;

@end