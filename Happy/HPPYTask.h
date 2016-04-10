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

// Use define because of poor possibilities with `NS_ENUM`, all will be better with Swift
#define HPPYTaskTypeText   @"text"
#define HPPYTaskTypeAudio  @"audio"

extern NSString * const hppyIdentifierKey;
extern NSString * const hppyTypeKey;
extern NSString * const hppyTitleKey;
extern NSString * const hppyTitlePersonalizedKey;
extern NSString * const hppyTitleUnpersonalizedKey;
extern NSString * const hppyBodyKey;
extern NSString * const hppyEstimatedTimeKey;
extern NSString * const hppyStartDateKey;
extern NSString * const hppyCategoryKey;
extern NSString * const hppyInTimeKey;
extern NSString * const hppyCompletedDateKey;
extern NSString * const hppyAttachementsKey;

@interface HPPYTask : NSObject <NSCoding>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titlePersonalized;
@property (nonatomic, strong) NSString *titleUnpersonalized;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSNumber *estimatedTime; // in seconds
@property (nonatomic, strong, getter=started) NSDate *startDate;
@property (nonatomic, assign) HPPYTaskCategory category;
@property (nonatomic, strong) NSArray *attachements;

- (instancetype)initWithIdentifier:(NSString *)identifier
                              type:(NSString *)type
                             title:(NSString *)title
                 titlePersonalized:(NSString *)titlePersonalized
               titleUnpersonalized:(NSString *)titleUnpersonalized
                              body:(NSString *)body
                     estimatedTime:(NSNumber *)estimatedTime
                          category:(HPPYTaskCategory)category
                      attachements:(NSArray *)attachements;
- (float)progress;
- (UIImage *)categoryImage;
- (UIColor *)categoryColor;
- (NSDictionary *)trackingData;

@end
