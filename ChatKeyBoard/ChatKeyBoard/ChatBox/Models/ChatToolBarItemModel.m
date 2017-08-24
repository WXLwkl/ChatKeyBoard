//
//  ChatToolBarItemModel.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "ChatToolBarItemModel.h"

@implementation ChatToolBarItemModel

+ (instancetype)barItemWithKind:(BarItemKind)itemKind
                         normal:(NSString*)normalStr
                           high:(NSString *)highLstr
                         select:(NSString *)selectStr {
    
    return [[[self class] alloc] initWithItemKind:itemKind
                                           normal:normalStr
                                             high:highLstr
                                           select:selectStr];
}


- (instancetype)initWithItemKind:(BarItemKind)itemKind
                          normal:(NSString*)normalStr
                            high:(NSString *)highLstr
                          select:(NSString *)selectStr {
    
    if (self = [super init]) {
        self.itemKind = itemKind;
        self.normalStr = normalStr;
        self.highLStr = highLstr;
        self.selectStr = selectStr;
    }
    return self;
}

@end
