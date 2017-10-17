//
//  InputEmoticonTabView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/28.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputEmoticonTabView;

@protocol InputEmoticonTabViewDelegate <NSObject>

- (void)tabView:(InputEmoticonTabView *)tabView didSelectTabIndex:(NSInteger) index;

@end

@interface InputEmoticonTabView : UIView

@property (nonatomic,strong) UIButton *sendButton;

@property (nonatomic,weak)   id<InputEmoticonTabViewDelegate> delegate;

- (void)selectTabIndex:(NSInteger)index;

- (void)loadCatalogs:(NSArray*)emoticonCatalogs;

@end
