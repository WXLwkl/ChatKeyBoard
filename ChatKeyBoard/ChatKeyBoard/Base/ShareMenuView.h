//
//  MorePanel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareMenuItemModel.h"

#define kShareMenuPageControlHeight 30

@protocol ShareMenuViewDelegate <NSObject>

@optional
/**
 *  点击第三方功能回调方法
 *
 *  @param shareMenuItem 被点击的第三方Model对象，可以在这里做一些特殊的定制
 *  @param index         被点击的位置
 */
- (void)didSelecteShareMenuItem:(ShareMenuItemModel *)shareMenuItem atIndex:(NSInteger)index;

@end



@interface ShareMenuView : UIView
/**
 *  第三方功能Models
 */
@property (nonatomic, strong) NSArray *shareMenuItems;
@property (nonatomic, weak) id<ShareMenuViewDelegate> delegate;
/**
 *  根据数据源刷新第三方功能按钮的布局
 */
- (void)reloadData;

@end
