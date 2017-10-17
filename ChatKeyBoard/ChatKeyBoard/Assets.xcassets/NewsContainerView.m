//
//  NewsContainerView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/18.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "NewsContainerView.h"

@implementation NewsContainerView

#pragma mark - Propertys

- (UILabel *)newsSummeryLabel {
    if (!_newsSummeryLabel) {
        _newsSummeryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.bounds) - 5 * 3 - 40, 40)];
        _newsSummeryLabel.numberOfLines = 2;
        _newsSummeryLabel.font = [UIFont systemFontOfSize:14];
        _newsSummeryLabel.textColor = [UIColor colorWithWhite:0.151 alpha:1.000];
        _newsSummeryLabel.backgroundColor = [UIColor clearColor];
        _newsSummeryLabel.text = @"这里是iOS开发者大会，欢迎来到华捷，我们今天的主题是群聊，大多数人会为群里的核心技术在哪里？";
    }
    return _newsSummeryLabel;
}

- (UIImageView *)newsThumbailImageView {
    if (!_newsThumbailImageView) {
        _newsThumbailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 40, 5, 40, 40)];
        _newsThumbailImageView.image = [UIImage imageNamed:@"dgame1"];
    }
    return _newsThumbailImageView;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.newsSummeryLabel];
        [self addSubview:self.newsThumbailImageView];
    }
    return self;
}

@end
