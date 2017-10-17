//
//  MorePanel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreItemModel.h"

@class MorePanel;

@protocol MorePanelDelegate <NSObject>

@optional
/**
 *  点击第三方功能回调方法
 *
 *  @param moreItem 被点击的第三方Model对象，可以在这里做一些特殊的定制
 *  @param index         被点击的位置
 */
- (void)didSelecteShareMenuItem:(MoreItemModel *)moreItem atIndex:(NSInteger)index;


@end


@interface MorePanel : UIView

/**
 *  第三方功能Models
 */
@property (nonatomic, strong) NSArray<MoreItemModel *> *shareMenuItems;

/**
 代理
 */
@property (nonatomic, weak) id<MorePanelDelegate> delegate;

@end
