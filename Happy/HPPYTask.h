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
    HPPYTaskCategory1 = 1,
    HPPYTaskCategory2,
    HPPYTaskCategory3,
    HPPYTaskCategory4
};

extern NSString * const hppyIdentifierKey;
extern NSString * const hppyTitleKey;
extern NSString * const hppyTitlePersonalizedKey;
extern NSString * const hppyBodyKey;
extern NSString * const hppyEstimatedTimeKey;
extern NSString * const hppyStartDateKey;
extern NSString * const hppyCategoryKey;
extern NSString * const hppyInTimeKey;
extern NSString * const hppyCompletedDateKey;

@interface HPPYTask : NSObject <NSCoding>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titlePersonalized;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSNumber *estimatedTime; // in seconds
@property (nonatomic, strong, getter=started) NSDate *startDate;
@property (nonatomic, assign) HPPYTaskCategory category;

-(instancetype)initWithIdentifier:(NSString *)identifier
                            title:(NSString *)title
                titlePersonalized:(NSString *)titlePersonalized
                             body:(NSString *)body
                    estimatedTime:(NSNumber *)estimatedTime
                         category:(HPPYTaskCategory)category;
- (float)progress;
- (UIImage *)categoryImage;
- (UIColor *)categoryColor;

@end
