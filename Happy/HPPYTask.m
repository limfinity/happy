//
//  HPPYTask.m
//  Happy
//
//  Created by Peter Pult on 19/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYTask.h"

@implementation HPPYTask

-(instancetype)initWithIdentifier:(NSString *)identifier
                            title:(NSString *)title
                titlePersonalized:(NSString *)titlePersonalized
                             body:(NSString *)body
                    estimatedTime:(NSNumber *)estimatedTime
                         category:(HPPYTaskCategory)category {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.title = title;
        self.titlePersonalized = titlePersonalized;
        self.body = body;
        self.estimatedTime = estimatedTime;
        self.category = category;
    }
    return self;
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
