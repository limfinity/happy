//
//  HPPYTask.m
//  Happy
//
//  Created by Peter Pult on 19/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTask.h"

NSString * const hppyIdentifierKey = @"identifier";
NSString * const hppyTitleKey = @"title";
NSString * const hppyTitlePersonalizedKey = @"titlePersonalized";
NSString * const hppyTitleUnpersonalizedKey = @"titleUnpersonalized";
NSString * const hppyBodyKey = @"body";
NSString * const hppyEstimatedTimeKey = @"estimatedTime";
NSString * const hppyStartDateKey = @"startDate";
NSString * const hppyCategoryKey = @"category";
NSString * const hppyInTimeKey = @"inTime";
NSString * const hppyCompletedDateKey = @"completedDate";

@implementation HPPYTask

-(instancetype)initWithIdentifier:(NSString *)identifier
                            title:(NSString *)title
                titlePersonalized:(NSString *)titlePersonalized
              titleUnpersonalized:(NSString *)titleUnpersonalized
                             body:(NSString *)body
                    estimatedTime:(NSNumber *)estimatedTime
                         category:(HPPYTaskCategory)category {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.title = title;
        self.titlePersonalized = titlePersonalized;
        self.titleUnpersonalized = titleUnpersonalized;
        self.body = body;
        self.estimatedTime = estimatedTime;
        self.category = category;
    }
    return self;
}

// MARK: NSCoding protocol
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.identifier = [coder decodeObjectForKey:hppyIdentifierKey];
        self.title = [coder decodeObjectForKey:hppyTitleKey];
        self.titlePersonalized = [coder decodeObjectForKey:hppyTitlePersonalizedKey];
        self.titleUnpersonalized = [coder decodeObjectForKey:hppyTitleUnpersonalizedKey];
        self.body = [coder decodeObjectForKey:hppyBodyKey];
        self.estimatedTime = [coder decodeObjectForKey:hppyEstimatedTimeKey];
        self.startDate = [coder decodeObjectForKey:hppyStartDateKey];
        self.category = [coder decodeIntegerForKey:hppyCategoryKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:hppyIdentifierKey];
    [aCoder encodeObject:self.title forKey:hppyTitleKey];
    [aCoder encodeObject:self.titlePersonalized forKey:hppyTitlePersonalizedKey];
    [aCoder encodeObject:self.titleUnpersonalized forKey:hppyTitleUnpersonalizedKey];
    [aCoder encodeObject:self.body forKey:hppyBodyKey];
    [aCoder encodeObject:self.estimatedTime forKey:hppyEstimatedTimeKey];
    [aCoder encodeObject:self.startDate forKey:hppyStartDateKey];
    [aCoder encodeInteger:self.category forKey:hppyCategoryKey];
}

// MARK: Public methods
- (float)progress {
    NSAssert(_startDate, @"Task has not been started.");
    
    float progress = (float)fabs([_startDate timeIntervalSinceNow]);
    progress = progress / [_estimatedTime floatValue];
    return MIN(progress, 1.0);
}

- (UIImage *)categoryImage {
    UIImage *image;
    NSString *imageName;
    switch (_category) {
        case HPPYTaskCategory1:
            imageName = @"iconBrain";
            break;
        case HPPYTaskCategory2:
            imageName = @"iconBubbles";
            break;
        case HPPYTaskCategory3:
            imageName = @"iconCloud";
            break;
        case HPPYTaskCategory4:
            imageName = @"iconMan";
            break;
    }
    image = [UIImage imageNamed:imageName];
    return image;
}

- (UIColor *)categoryColor {
    UIColor *color;
    switch (_category) {
        case HPPYTaskCategory1:
            color = [UIColor colorWithRed:0xa7/255.0 green:0xe3/255.0 blue:0xf7/255.0 alpha:1.0];
            break;
        case HPPYTaskCategory2:
            color = [UIColor colorWithRed:0xff/255.0 green:0xe8/255.0 blue:0x8e/255.0 alpha:1.0];
            break;
        case HPPYTaskCategory3:
            color = [UIColor colorWithRed:0xff/255.0 green:0xcd/255.0 blue:0xa6/255.0 alpha:1.0];
            break;
        case HPPYTaskCategory4:
            color = [UIColor colorWithRed:0xb1/255.0 green:0xe4/255.0 blue:0xdd/255.0 alpha:1.0];
            break;
    }
    return color;
}

@end
