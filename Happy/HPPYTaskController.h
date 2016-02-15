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

/// Gets the next task in order after a given task, shows first task if no next task is available
- (HPPYTask *)nextTask:(HPPYTask *)previousTask;

/// Marks a task as completed and persists the result in a file
- (void)completeTask:(HPPYTask *)task;

@end
