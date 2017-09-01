//
//  MoreItemModel.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MoreItemModel.h"

@implementation MoreItemModel

+ (instancetype)moreItemWithPicName:(NSString *)pickName
                  highLightPicName:(NSString *)highLightPicName
                           itemName:(NSString *)itemName {
    return [[self alloc] initWithPicName:pickName highLightPicName:highLightPicName itemName:itemName];
}
- (instancetype)initWithPicName:(NSString *)picName highLightPicName:(NSString *)highLightPicName itemName:(NSString *)itemName {
    self = [super init];
    if (self) {
        if (picName.length == 0) {
            picName = nil;
        }
        if (highLightPicName.length == 0) {
            highLightPicName = nil;
        }
        self.itemName = itemName;
        self.itemPicName = picName;
        self.itemHightlightPicName = highLightPicName;
    }
    return self;
}
@end
