//
//  MorePanel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorePanel;

@protocol MorePanelDelegate <NSObject>

@optional
- (void)morePanel:(MorePanel *)morePanel didSelectItemIndex:(NSInteger)index;

@end


@interface MorePanel : UIView

@property (nonatomic, weak) id<MorePanelDelegate> delegate;

+ (instancetype)morePannel;

@end
