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
    HPPYTask *_currenTask;
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
    
    if (_currenTask) {
        task = _currenTask;
    } else {
        task = [_tasks firstObject];
    }
    
    return task;
}

- (HPPYTask *)nextTask:(HPPYTask *)previousTask {
    HPPYTask *task;
    
    int index = (int)[_tasks indexOfObject:previousTask] + 1;
    index = index < _tasks.count ? index : 0;
    task = _tasks[index];
    _currenTask = task;
    
    return task;
}

- (void)completeTask:(HPPYTask *)task {
    // TODO: log task results either skipped or finished
}


// MARK: Private methods
- (NSArray *)getTasks {
    NSMutableArray *tasks = [NSMutableArray new];
    NSArray *array = [HPPY getArrayFromFile:@"tasks.plist" reloadFromBundle:YES];
    
    // TODO: Use nscopying protocol
    for (NSDictionary *dict in array) {
        HPPYTask *task = [[HPPYTask alloc] initWithIdentifier:dict[@"identifier"] title:dict[@"title"] titlePersonalized:dict[@"titlePersonalized"] body:dict[@"body"] estimatedTime:dict[@"estimatedTime"] category:[dict[@"category"] integerValue]];
        [tasks addObject:task];
    }
    
    return tasks;
}

@end
