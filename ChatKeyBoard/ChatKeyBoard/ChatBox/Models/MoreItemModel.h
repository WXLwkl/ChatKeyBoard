//
//  MoreItemModel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreItemModel : NSObject

@property (nonatomic, copy) NSString *itemPicName;
@property (nonatomic, copy) NSString *itemHightlightPicName;
@property (nonatomic, copy) NSString *itemName;

+ (instancetype)moreItemWithPicName:(NSString *)pickName highLightPicName:(NSString *)highLightPicName itemName:(NSString *)itemName;


@end
