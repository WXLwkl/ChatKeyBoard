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
        self.backgroundColor = [UIColor grayColor];
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        _switchBtn.frame = CGRectMake(0, 0, 44, kChatToolBarHeight);
        [self addSubview:_switchBtn];
    }
    return self;
}

- (void)switchAction:(UIButton *)btn {
    if (self.switchAction) {
        self.switchAction();
    }
}
@end
