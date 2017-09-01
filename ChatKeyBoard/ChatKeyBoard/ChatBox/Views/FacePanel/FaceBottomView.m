//
//  FaceBottomView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/31.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "FaceBottomView.h"
#import "Header.h"


@interface FaceBottomView ()

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIScrollView *facePickerView;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *setBtn;

@end

@implementation FaceBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
    [self addSubview:self.addBtn];
    [self addSubview:self.facePickerView];
    [self addSubview:self.setBtn];
    [self addSubview:self.sendBtn];
}

- (void)layoutSubviews {
    self.addBtn.frame = CGRectMake(0, 0, kFacePanelBottomToolBarWidth, self.frame.size.height);
    self.facePickerView.frame = CGRectMake(kFacePanelBottomToolBarWidth, 0, self.frame.size.width - kFacePanelBottomToolBarWidth, self.frame.size.height);
    self.sendBtn.frame = CGRectMake(self.frame.size.width-kFacePanelBottomToolBarWidth-10, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
    self.setBtn.frame = self.sendBtn.frame;
//    self.sendBtn.frame = (CGRect){CGPointMake(<#CGFloat x#>, CGSizeMake(<#CGFloat width#>, <#CGFloat height#>))};
}
#pragma mark - 对外接口
- (void)loadFaceSubjectPickerSource:(NSArray<FaceSubjectModel *> *)pickerSource {
    
    for (int i = 0; i < pickerSource.count; i++) {
        FaceSubjectModel *subjectModel = pickerSource[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            btn.selected = YES;
        }
        btn.tag = i + 100;
        [btn setTitle:subjectModel.subjectTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(subjectPicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.frame = CGRectMake(i*kFacePanelBottomToolBarWidth, 0, kFacePanelBottomToolBarWidth, self.frame.size.height);
        [self.facePickerView addSubview:btn];
    }
}
- (void)changeFaceSubjectIndex:(NSInteger)subjectIndex {
    
    [self.facePickerView setContentOffset:CGPointMake(subjectIndex * kFacePanelBottomToolBarWidth, 0) animated:YES];
    
    for (UIView *sub in self.facePickerView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            if (btn.tag - 100 == subjectIndex) {
                btn.selected = YES;
            } else {
                btn.selected = NO;
            }
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
       
        if (subjectIndex > 0) {
            self.setBtn.frame = CGRectMake(self.frame.size.width-kFacePanelBottomToolBarWidth-10, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
            self.sendBtn.frame = CGRectMake(self.frame.size.width, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
        } else {
            self.sendBtn.frame = CGRectMake(self.frame.size.width-kFacePanelBottomToolBarWidth-10, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
            self.setBtn.frame = CGRectMake(self.frame.size.width, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
        }
    }];
}
#pragma mark - event response

- (void)subjectPicBtnClick:(UIButton *)sender {
    for (UIView *sub in _facePickerView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            if (btn == sender) {
                sender.selected = YES;
            }else {
                btn.selected = NO;
            }
        }
    }

    [UIView animateWithDuration:0.5 animations:^{
        
        if (sender.tag - 100 > 0) {
            self.setBtn.frame = CGRectMake(self.frame.size.width-kFacePanelBottomToolBarWidth-10, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
            self.sendBtn.frame = CGRectMake(self.frame.size.width, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
        } else {
            self.sendBtn.frame = CGRectMake(self.frame.size.width-kFacePanelBottomToolBarWidth-10, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
            self.setBtn.frame = CGRectMake(self.frame.size.width, 0, kFacePanelBottomToolBarWidth+10, self.frame.size.height);
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(faceBottomView:didPickerFaceSubjectIndex:)]) {
        [self.delegate faceBottomView:self didPickerFaceSubjectIndex:sender.tag-100];
    }
}

- (void)addBtnClick:(UIButton *)sender {
    if (self.addAction) {
        self.addAction();
    }
}
- (void)sendBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(faceBottomViewSendAction:)]) {
        [self.delegate faceBottomViewSendAction:self];
    }
}
- (void)setBtnClick:(UIButton *)sender {
    if (self.setAction) {
        self.setAction();
    }
}
#pragma mark - lazy
- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addBtn setBackgroundColor:[UIColor grayColor]];
        [_addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}
- (UIScrollView *)facePickerView {
    if (!_facePickerView) {
        _facePickerView = [[UIScrollView alloc] init];
        _facePickerView.showsVerticalScrollIndicator = NO;
        _facePickerView.showsHorizontalScrollIndicator = NO;
    }
    return _facePickerView;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setBackgroundColor:[UIColor grayColor]];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}
- (UIButton *)setBtn {
    if (!_setBtn) {
        _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setBtn setBackgroundColor:[UIColor grayColor]];
        [_setBtn setTitle:@"设置" forState:UIControlStateNormal];
        [_setBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_setBtn addTarget:self action:@selector(setBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setBtn;
}
@end
