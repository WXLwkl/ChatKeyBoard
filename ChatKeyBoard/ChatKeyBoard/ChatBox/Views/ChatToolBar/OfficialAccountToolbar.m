//
//  OfficialAccountToolbar.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "OfficialAccountToolbar.h"
#import "Header.h"

@implementation OfficialAccountToolbar
{
    UIButton *_switchBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchBtn setImage:[UIImage imageNamed:@"switchUp"] forState:UIControlStateNormal];
        [_switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        _switchBtn.frame = CGRectMake(0, 0, 44, kChatToolBarHeight);
        [self addSubview:_switchBtn];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(45, 0, 1, kChatToolBarHeight)];
        line.backgroundColor = RGBColor(204, 204, 206);
        [self addSubview:line];
    }
    return self;
}

- (void)switchAction:(UIButton *)btn {
    if (self.switchAction) {
        self.switchAction();
    }
}
@end
