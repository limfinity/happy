//
//  HPPYTaskController.m
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskController.h"

@interface HPPYTaskController () {
    NSArray *_tasks;
}

@end

@implementation HPPYTaskController

// MARK: Public methods
- (instancetype)init {
    self = [super init];
    
    if (self) {
        _tasks = [self getTasks];
    }
    
    return self;
}

- (HPPYTask *)currentTask {
    HPPYTask *task;
    task = _tasks[0];
    
    return task;
}

- (HPPYTask *)nextTask:(HPPYTask *)previousTask {
    HPPYTask *task;
    int index = (int)[_tasks indexOfObject:previousTask] + 1;
    index = index < _tasks.count ? index : 0;
    task = _tasks[index];
    
    return task;
}

- (void)completeTask:(HPPYTask *)task {
    // TODO: log task results either skipped or finished
}


// MARK: Private methods
- (NSArray *)getTasks {
    NSMutableArray *tasks = [NSMutableArray new];
    NSArray *array = [self getArrayFromFile:@"tasks.plist" reloadFromBundle:YES];
    
    // TODO: Use nscopying protocol
    for (NSDictionary *dict in array) {
        HPPYTask *task = [[HPPYTask alloc] initWithIdentifier:dict[@"identifier"] title:dict[@"title"] titlePersonalized:dict[@"titlePersonalized"] body:dict[@"body"] estimatedTime:dict[@"estimatedTime"] category:[dict[@"category"] integerValue]];
        [tasks addObject:task];
    }
    
    return tasks;
}

- (NSArray *)getArrayFromFile:(NSString *)fileName reloadFromBundle:(BOOL)reload {
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
                NSLog(@"Error removing remove old file %@: %@", fileName, error.description);
                return nil;
            }
        }
        
        if (![fileManager copyItemAtPath:bundle toPath: path error:&error]) {
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
