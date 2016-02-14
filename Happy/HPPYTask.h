//
//  HPPYTask.h
//  Happy
//
//  Created by Peter Pult on 19/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HPPYTaskCategory) {
    HPPYTaskCategory1,
    HPPYTaskCategory2,
    HPPYTaskCategory3,
    HPPYTaskCategory4
};

@interface HPPYTask : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titlePersonalized;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSNumber *estimatedTime; // in seconds
@property (nonatomic, assign) HPPYTaskCategory category;

-(instancetype)initWithIdentifier:(NSString *)identifier
                            title:(NSString *)title
                titlePersonalized:(NSString *)titlePersonalized
                             body:(NSString *)body
                    estimatedTime:(NSNumber *)estimatedTime
                         category:(HPPYTaskCategory)category;
- (UIImage *)categoryImage;
- (UIColor *)categoryColor;

@end
