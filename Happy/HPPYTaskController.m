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
    [HPPYTaskController updateCurrentTask:task];
    return task;
}

+ (void)startTask:(HPPYTask *)task {
    if (!task.started) {
        task.startDate = [NSDate date];
        [HPPYTaskController updateCurrentTask:task];
    }
}

- (HPPYTask *)skipTask:(HPPYTask *)task {
    return [self nextTask:task];
}

- (HPPYTask *)completeTask:(HPPYTask *)task {
    [self saveTaskEvent:[self completionEventFromTask:task]];
    return [self nextTask:task];
}

+ (NSDate *)getLastCompletionDateFromTask:(HPPYTask *)task {
    NSArray *taskEvents = [[self getTaskEvents] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1[hppyCompletedDateKey] < obj2[hppyCompletedDateKey];
    }];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@", hppyIdentifierKey, task.identifier];
    NSUInteger index = [taskEvents indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [predicate evaluateWithObject:obj];
    }];
    NSDate *lastCompletionDate;
    if (index != NSNotFound) {
        lastCompletionDate = taskEvents[index][hppyCompletedDateKey];
    } else {
        lastCompletionDate = nil;
    }
    return lastCompletionDate;
}

// MARK: Private methods
-(NSDictionary *)completionEventFromTask:(HPPYTask *)task {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSDate *now = [NSDate date];
    dict[hppyCompletedDateKey] = now;
    dict[hppyInTimeKey] = @([now timeIntervalSinceDate:task.startDate]);
    dict[hppyIdentifierKey] = task.identifier;
    return dict;
}

+ (void)updateCurrentTask:(HPPYTask *)task {
    NSData *taskData = [NSKeyedArchiver archivedDataWithRootObject:task];
    [[NSUserDefaults standardUserDefaults] setObject:taskData forKey:@"hppyCurrentTask"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (HPPYTask *)nextTask:(HPPYTask *)previousTask {
    // Reset the current task
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hppyCurrentTask"];
    
    HPPYTask *task;
    
    NSUInteger index = [self getIndexOfTask:previousTask];
    if (index == NSNotFound) {
        index = 0;
    } else {
        index++;
    }
    index = index < _tasks.count ? index : 0;
    task = _tasks[index];
    task.startDate = nil;
    [HPPYTaskController updateCurrentTask:task];
    
    return task;
}

- (NSUInteger)getIndexOfTask:(HPPYTask *)task {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@", hppyIdentifierKey, task.identifier];
    NSUInteger index = [_tasks indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [predicate evaluateWithObject:obj];
    }];
    return index;
}

- (void)saveTaskEvent:(NSDictionary *)event {
    NSMutableArray *events = [NSMutableArray arrayWithArray:[HPPYTaskController getTaskEvents]];
    [events addObject:event];
    if (![HPPY writeArray:events toFile:@"hppyTaskEvents.plist"]) {
        NSLog(@"Error saving last task event.");
    }
}

+ (NSArray *)getTaskEvents {
    NSArray *array = [HPPY getArrayFromFile:@"hppyTaskEvents.plist" reloadFromBundle:NO];
    return array;
}

+ (NSArray *)getTasks {
    NSMutableArray *tasks = [NSMutableArray new];
    NSArray *array = [HPPY getArrayFromFile:@"hppyTasks.plist" reloadFromBundle:YES];
    
    for (NSDictionary *dict in array) {
        HPPYTask *task = [[HPPYTask alloc] initWithIdentifier:dict[hppyIdentifierKey]
                                                        title:dict[hppyTitleKey]
                                            titlePersonalized:dict[hppyTitlePersonalizedKey]
                                          titleUnpersonalized:dict[hppyTitleUnpersonalizedKey]
                                                         body:dict[hppyBodyKey]
                                                estimatedTime:dict[hppyEstimatedTimeKey]
                                                     category:[dict[hppyCategoryKey] integerValue]];
        [tasks addObject:task];
    }
    
    return tasks;
}

@end
