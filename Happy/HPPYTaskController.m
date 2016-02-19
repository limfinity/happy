//
//  HPPYTaskController.m
//  Happy
//
//  Created by Peter Pult on 05/12/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTaskController.h"
#import "HPPY.h"

@interface HPPYTaskController () {
    NSArray *_tasks;
}

@end

@implementation HPPYTaskController

// MARK: Public methods
- (instancetype)init {
    self = [super init];
    
    if (self) {
        _tasks = [HPPYTaskController getTasks];
    }
    
    return self;
}

+ (HPPYTask *)currentTask {
    NSData *taskData = [[NSUserDefaults standardUserDefaults] objectForKey:@"hppyCurrentTask"];
    if (taskData) {
        HPPYTask *task = [NSKeyedUnarchiver unarchiveObjectWithData:taskData];
        if (task) {
            return task;
        }
    }
    
    HPPYTask* task = [[HPPYTaskController getTasks] firstObject];
    [HPPYTaskController setCurrentTask:task];
    return task;
}

+ (void)setCurrentTask:(HPPYTask *)task {
    [task save]; // Saves task as current task
}

- (HPPYTask *)nextTask:(HPPYTask *)previousTask {
    HPPYTask *task;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@", hppyIdentifierKey, previousTask.identifier];
    NSUInteger index = [_tasks indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [predicate evaluateWithObject:obj];
    }];
    if (index == NSNotFound) {
        index = 0;
    } else {
        index++;
    }
    index = index < _tasks.count ? index : 0;
    task = _tasks[index];
    [HPPYTaskController setCurrentTask:task];
    
    return task;
}

- (void)completeTask:(HPPYTask *)task {
    // TODO: log task results either skipped or finished
}

// MARK: Private methods
+ (NSArray *)getTasks {
    NSMutableArray *tasks = [NSMutableArray new];
    NSArray *array = [HPPY getArrayFromFile:@"hppyTasks.plist" reloadFromBundle:YES];
    
    for (NSDictionary *dict in array) {
        HPPYTask *task = [[HPPYTask alloc] initWithIdentifier:dict[hppyIdentifierKey]
                                                        title:dict[hppyTitleKey]
                                            titlePersonalized:dict[hppyTitlePersonalizedKey]
                                                         body:dict[hppyBodyKey]
                                                estimatedTime:dict[hppyEstimatedTimeKey]
                                                     category:[dict[hppyCategoryKey] integerValue]];
        [tasks addObject:task];
    }
    
    return tasks;
}

@end
