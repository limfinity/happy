//
//  HPPYTaskController.h
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPPYTask.h"

@interface HPPYTaskController : NSObject

/// Gets the task where user left off
+ (HPPYTask *)currentTask;

/// Starts the given task
+ (void)startTask:(HPPYTask *)task;

/// Skips the given task and returns the next task
- (HPPYTask *)skipTask:(HPPYTask *)task;

/// Marks a task as completed and persists the result in a file; return the next task
- (HPPYTask *)completeTask:(HPPYTask *)task;

/// Returns the last date a given task was completed, `nil` when task hsa never been completed before
+ (NSDate *)getLastCompletionDateFromTask:(HPPYTask *)task;

/// Returns an array with all tasks
+ (NSArray *)getTasks;

@end
