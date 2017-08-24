//
//  ChatToolBarItemModel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BarItemKind) {
    BarItemVoice,
    BarItemFace,
    BarItemMore,
    BarItemSwitchBar
};

@interface ChatToolBarItemModel : NSObject

@property (nonatomic, copy) NSString *normalStr;
@property (nonatomic, copy) NSString *highLStr;
@property (nonatomic, copy) NSString *selectStr;
@property (nonatomic, assign) BarItemKind itemKind;

+ (instancetype)barItemWithKind:(BarItemKind)itemKind
                         normal:(NSString*)normalStr
                           high:(NSString *)highLstr
                         select:(NSString *)selectStr;

@end
