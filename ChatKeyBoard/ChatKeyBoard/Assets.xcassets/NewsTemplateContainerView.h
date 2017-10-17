//
//  NewsTemplateContainerView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/18.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNewsTemplateContainerViewHeight 360
#define kNewsTemplateContainerViewSpacing 10

@interface NewsTemplateContainerView : UIView

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *topNewsImageView;
@property (nonatomic, strong) UILabel *topNewsTitleLabel;

@end
