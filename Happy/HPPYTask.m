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
        case HPPYTaskCategoryActivity:
            imageName = @"";
            break;
        case HPPYTaskCategoryMeditation:
            imageName = @"";
            break;
        case HPPYTaskCategoryThinking:
            imageName = @"";
            break;
    }
    image = [UIImage imageNamed:imageName];
    
    if (!image) {
        image = [UIImage imageNamed:@"categoryDefault"];
    }
    
    return image;
}

@end
