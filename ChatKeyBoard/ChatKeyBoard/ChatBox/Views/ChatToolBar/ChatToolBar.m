//
//  ChatToolBar.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "ChatToolBar.h"
#import "Header.h"
#import "ChatToolBarItemModel.h"
typedef NS_ENUM(NSInteger, BtnKind) {
    BtnKindVoice,
    BtnKindFace,
    BtnKindMore,
    BtnKindSwitchBar
};


#define Image(str)              (str == nil || str.length == 0) ? nil : [UIImage imageNamed:str]
#define ItemW                   44                  //44
#define ItemH                   kChatToolBarHeight  //49
#define TextViewH               36
#define TextViewVerticalOffset  (ItemH-TextViewH)/2.0


@interface ChatToolBar ()<UITextViewDelegate>

@property CGFloat previousTextViewHeight;

/** 临时记录输入的textView */
@property (nonatomic, copy) NSString *currentText;

@property (nonatomic, strong) UIButton *switchBarBtn;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UIButton *faceBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) XLTextView *textView;
@property (nonatomic, strong) RecordButton *recordBtn;

@property (readwrite) BOOL voiceSelected;
@property (readwrite) BOOL faceSelected;
@property (readwrite) BOOL moreFuncSelected;
@property (readwrite) BOOL switchBarSelected;


@end

@implementation ChatToolBar

#pragma mark -- dealloc

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.textView.contentSize"];
}

#pragma mark -- init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValue];
        [self initSubviews];
    }
    return self;
}
- (void)setDefaultValue {
    self.allowSwitchBar = NO;
    self.allowVoice = YES;
    self.allowFace = YES;
    self.allowMoreFunc = YES;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.previousTextViewHeight = TextViewH;
    
    // addSubView
    self.switchBarBtn = [self createBtn:BtnKindSwitchBar action:@selector(toolbarBtnClick:)];
    self.switchBarBtn.hidden = YES;
    self.voiceBtn = [self createBtn:BtnKindVoice action:@selector(toolbarBtnClick:)];
    self.faceBtn = [self createBtn:BtnKindFace action:@selector(toolbarBtnClick:)];
    self.moreBtn = [self createBtn:BtnKindMore action:@selector(toolbarBtnClick:)];
    self.recordBtn = [[RecordButton alloc] init];
    
    self.textView = [[XLTextView alloc] init];
    self.textView.frame = CGRectMake(0, 0, 0, TextViewH);
    self.textView.delegate = self;
    
    [self addSubview:self.voiceBtn];
    [self addSubview:self.faceBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.switchBarBtn];
    [self addSubview:self.textView];
    [self addSubview:self.recordBtn];
    
    //设置frame
    [self setbarSubViewsFrame];
    
    //KVO
    [self addObserver:self forKeyPath:@"self.textView.contentSize" options:(NSKeyValueObservingOptionNew) context:nil];
    
    __weak __typeof(self) weakSelf = self;
    
    self.recordBtn.recordTouchDownAction = ^(RecordButton *recordButton) {
        NSLog(@"开始录音");
        if (recordButton.highlighted) {
            recordButton.highlighted = YES;
            [recordButton setButtonStateWithRecording];
        }
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolBarDidStartRecording:)]) {
            [weakSelf.delegate chatToolBarDidStartRecording:weakSelf];
        }
    };
    self.recordBtn.recordTouchUpInsideAction = ^(RecordButton *recordButton) {
        NSLog(@"完成录音");
        [recordButton setButtonStateWithNormal];
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolBarDidFinishRecoding:)]) {
            [weakSelf.delegate chatToolBarDidFinishRecoding:weakSelf];
        }
    };
    self.recordBtn.recordTouchUpOutsideAction = ^(RecordButton *recordButton) {
        NSLog(@"取消录音");
        [recordButton setButtonStateWithNormal];
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolBarDidCancelRecording:)]) {
            [weakSelf.delegate chatToolBarDidCancelRecording:weakSelf];
        }
    };
    //持续调用
    self.recordBtn.recordTouchDragInsideAction = ^(RecordButton *recordButton) {
        
    };
    //持续调用
    self.recordBtn.recordTouchDragOutsideAction = ^(RecordButton *recordButton) {
        
    };
    //中间状态 从TouchDragInside --> TouchDragOutside
    self.recordBtn.recordTouchDragExitAction = ^(RecordButton *recordButton) {
        NSLog(@"将要取消录音");
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolBarWillCancelRecoding:)]) {
            [weakSelf.delegate chatToolBarWillCancelRecoding:weakSelf];
        }
    };
    //中间状态 从TouchDragOutSide --> TouchDragInside
    self.recordBtn.recordTouchDragEnterAction = ^(RecordButton *recordButton) {
        NSLog(@"继续录音");
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolBarContineRecording:)]) {
            [weakSelf.delegate chatToolBarContineRecording:weakSelf];
        }
    };
}

- (void)setbarSubViewsFrame {
    CGFloat barViewH = self.frame.size.height;
    if (self.allowSwitchBar) {
        self.switchBarBtn.frame = CGRectMake(0, barViewH - ItemH, ItemW, ItemH);
    } else {
        self.switchBarBtn.frame = CGRectZero;
    }
    if (self.allowVoice) {
        self.voiceBtn.frame = CGRectMake(CGRectGetMaxX(self.switchBarBtn.frame), barViewH - ItemH, ItemW, ItemH);
    } else {
        self.voiceBtn.frame = CGRectZero;
    }
    if (self.allowMoreFunc) {
        self.moreBtn.frame = CGRectMake(self.frame.size.width - ItemW, barViewH - ItemH, ItemW, ItemH);
    } else {
        self.moreBtn.frame = CGRectZero;
    }
    if (self.allowFace) {
        self.faceBtn.frame = CGRectMake(CGRectGetMinX(self.moreBtn.frame) - ItemW, barViewH- ItemH, ItemW, ItemH);
    } else {
        self.faceBtn.frame = CGRectZero;
    }
    self.textView.frame = CGRectMake(CGRectGetMaxX(self.voiceBtn.frame), TextViewVerticalOffset, CGRectGetMinX(self.faceBtn.frame) - CGRectGetMaxX(self.voiceBtn.frame) , self.textView.frame.size.height);
    
    self.recordBtn.frame = self.textView.frame;
}

#pragma mark -- 对外接口
- (void)loadBarItems:(NSArray<ChatToolBarItemModel *>  *)barItems {
    for (ChatToolBarItemModel *model in barItems)
    {
        [self setBtn:(NSInteger)model.itemKind normalStateImageStr:model.normalStr selectStateImageStr:model.selectStr highLightStateImageStr:model.highLStr];
    }
}
- (void)setTextViewContent:(NSString *)text {
    
    self.currentText = self.textView.text = text;
}
- (void)clearTextViewContent {
    self.currentText = self.textView.text = @"";
}
- (void)setTextViewPlaceHolder:(NSString *)placeholder {
    if (placeholder == nil) {
        return;
    }
    
    self.textView.placeHolder = placeholder;
}

- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor {
    if (placeHolderColor == nil) {
        return;
    }
    self.textView.placeHolderTextColor = placeHolderColor;
}

#pragma mark -- 重新配置各个按钮
- (void)prepareForBeginComment {
    self.voiceSelected = self.voiceBtn.selected = NO;
    self.faceSelected = self.faceBtn.selected = NO;
    self.moreFuncSelected = self.moreBtn.selected = NO;
    self.recordBtn.hidden = YES;
    self.textView.hidden = NO;
}
- (void)prepareForEndComment {
    self.voiceSelected = self.voiceBtn.selected = NO;
    self.faceSelected = self.faceBtn.selected = NO;
    self.moreFuncSelected = self.moreBtn.selected = NO;
    self.recordBtn.hidden = YES;
    self.textView.hidden = NO;
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark -- 关于按钮
- (void)setBtn:(BtnKind)btnKind normalStateImageStr:(NSString *)normalStr
selectStateImageStr:(NSString *)selectStr highLightStateImageStr:(NSString *)highLightStr
{
    UIButton *btn;
    
    switch (btnKind) {
        case BtnKindFace:
            btn = self.faceBtn;
            break;
        case BtnKindMore:
            btn = self.moreBtn;
            break;
        case BtnKindVoice:
            btn = self.voiceBtn;
            break;
        case BtnKindSwitchBar:
            btn = self.switchBarBtn;
            break;
        default:
            break;
    }
    [btn setImage:Image(normalStr) forState:UIControlStateNormal];
    [btn setImage:Image(selectStr) forState:UIControlStateSelected];
    [btn setImage:Image(highLightStr) forState:UIControlStateHighlighted];
}

- (UIButton *)createBtn:(BtnKind)btnKind action:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    switch (btnKind) {
        case BtnKindVoice:
            btn.tag = 1;
            break;
        case BtnKindFace:
            btn.tag = 2;
            break;
        case BtnKindMore:
            btn.tag = 3;
            break;
        case BtnKindSwitchBar:
            btn.tag = 4;
            break;
    }
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    return btn;
}

#pragma mark -- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.voiceSelected = self.voiceBtn.selected = NO;
    self.faceSelected = self.faceBtn.selected = NO;
    self.moreFuncSelected = self.moreBtn.selected = NO;
    
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDidBeginEditing:)]) {
        [self.delegate chatToolBarTextViewDidBeginEditing:self.textView];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(chatToolBarSendText:)]) {
            self.currentText = @"";
            [self.delegate chatToolBarSendText:textView.text];
        }
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.currentText = textView.text;
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDidChange:)]) {
        [self.delegate chatToolBarTextViewDidChange:self.textView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == self && [keyPath isEqualToString:@"self.textView.contentSize"]) {
        [self layoutAndAnimateTextView:self.textView];
    }
}

- (void)layoutAndAnimateTextView:(XLTextView *)textView {
    
    CGFloat maxHeight = [self fontWidth] * [self maxLines];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewHeight;
    CGFloat changeInHeight = contentH - self.previousTextViewHeight;
    if (!isShrinking && (self.previousTextViewHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    } else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewHeight);
    }
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f animations:^{
            if (isShrinking) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                    self.previousTextViewHeight = MIN(contentH, maxHeight);
                }
                [self adjustTextViewHeightBy:changeInHeight];
            }
            CGRect inputViewFrame = self.frame;
            self.frame = CGRectMake(0.0f, 0, inputViewFrame.size.width, (inputViewFrame.size.height + changeInHeight));
            
            if (!isShrinking) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                    self.previousTextViewHeight = MIN(contentH, maxHeight);
                }
                [self adjustTextViewHeightBy:changeInHeight];
            }
        }];
        self.previousTextViewHeight = MIN(contentH, maxHeight);
    }
    if (self.previousTextViewHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.width);
            [textView setContentOffset:bottomOffset animated:YES];
        });
    }
}
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    
    CGRect prevFrame = self.textView.frame;
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText], [[self.textView.text componentsSeparatedByString:@"\n"] count] + 1);
    self.textView.frame = CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width, prevFrame.size.height + changeInHeight);
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f), 0.0f, (numLines >= 6 ? 4.0f : 0.0f), 0.0f);
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 2, 1)];
    }
}
#pragma mark -- 工具栏按钮点击事件
- (void)toolbarBtnClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            [self handelVoiceClick:sender];
            break;
        }
        case 2:
        {
            [self handelFaceClick:sender];
            break;
        }
        case 3:
        {
            [self handelMoreClick:sender];
            break;
        }
        case 4:
        {
            [self handelSwitchBarClick:sender];
            break;
        }

    }
}

- (void)handelVoiceClick:(UIButton *)sender {
    self.voiceSelected = self.voiceBtn.selected = !self.voiceBtn.selected;
    self.faceSelected = self.faceBtn.selected = NO;
    self.moreFuncSelected = self.moreBtn.selected = NO;
    BOOL keyBoardChanged = YES;
    
    if (sender.selected) {
        if (!self.textView.isFirstResponder) {
            keyBoardChanged = NO;
        }
        [self adjustTextViewContentSize];
        [self.textView resignFirstResponder];
    } else {
        
        [self resumeTextViewContentSize];
        [self.textView becomeFirstResponder];
    }
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.recordBtn.hidden = !sender.selected;
        self.textView.hidden = sender.selected;
    } completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(chatToolBar:voiceBtnPressed:keyBoardState:)]) {
        [self.delegate chatToolBar:self voiceBtnPressed:sender.selected keyBoardState:keyBoardChanged];
    }
}
- (void)handelFaceClick:(UIButton *)sender {
    self.faceSelected = self.faceBtn.selected = !self.faceBtn.selected;
    self.voiceSelected = self.voiceBtn.selected = NO;
    self.moreFuncSelected = self.moreBtn.selected = NO;
    BOOL keyBoardChanged = YES;
    if (sender.selected) {
        if (!self.textView.isFirstResponder) {
            keyBoardChanged = NO;
        }
        [self.textView resignFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
    [self resumeTextViewContentSize];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.recordBtn.hidden = YES;
        self.textView.hidden = NO;
    } completion:nil];
    if ([self.delegate respondsToSelector:@selector(chatToolBar:faceBtnPressed:keyBoardState:)]) {
        [self.delegate chatToolBar:self faceBtnPressed:sender.selected keyBoardState:keyBoardChanged];
    }
}
- (void)handelMoreClick:(UIButton *)sender {
    
    self.moreFuncSelected = self.moreBtn.selected = !self.moreBtn.selected;
    self.voiceSelected = self.voiceBtn.selected = NO;
    self.faceSelected = self.faceBtn.selected = NO;
    
    BOOL keyBoardChanged = YES;
    
    if (sender.selected) {
        if (!self.textView.isFirstResponder) {
            keyBoardChanged = NO;
        }
        [self.textView resignFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
    
    [self resumeTextViewContentSize];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.recordBtn.hidden = YES;
        self.textView.hidden = NO;
    } completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(chatToolBar:moreBtnPressed:keyBoardState:)]) {
        [self.delegate chatToolBar:self moreBtnPressed:sender.selected keyBoardState:keyBoardChanged];
    }
}
- (void)handelSwitchBarClick:(UIButton *)sender {
    
    BOOL keyBoardChanged = YES;
    
    self.faceSelected = self.faceBtn.selected = NO;
    self.moreFuncSelected =  self.moreBtn.selected = NO;
    
    if (!self.textView.isFirstResponder) {
        
        keyBoardChanged = NO;
    }
    
    [self.textView resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(chatToolBarSwitchToolBarBtnPressed:keyBoardState:)]) {
        [self.delegate chatToolBarSwitchToolBarBtnPressed:self keyBoardState:keyBoardChanged];
    }
}

#pragma mark - setter
- (void)setAllowSwitchBar:(BOOL)allowSwitchBar {
    _allowSwitchBar = allowSwitchBar;
    
    self.switchBarBtn.hidden = !_allowSwitchBar;
    [self setbarSubViewsFrame];
}

- (void)setAllowVoice:(BOOL)allowVoice {
    
    _allowVoice = allowVoice;
    
    self.voiceBtn.hidden = !_allowVoice;
    [self setbarSubViewsFrame];
}
- (void)setAllowFace:(BOOL)allowFace {
    _allowFace = allowFace;
    
    self.faceBtn.hidden = !_allowFace;
    [self setbarSubViewsFrame];
}
- (void)setAllowMoreFunc:(BOOL)allowMoreFunc {
    
    _allowMoreFunc = allowMoreFunc;
    
    self.moreBtn.hidden = !_allowMoreFunc;
    [self setbarSubViewsFrame];
}

- (void)adjustTextViewContentSize {
    //调整textView和recordBtn的frame
    self.currentText = self.textView.text;
    self.textView.text = @"";
    self.textView.contentSize = CGSizeMake(CGRectGetWidth(self.textView.frame), TextViewH);
    self.recordBtn.frame = CGRectMake(self.textView.frame.origin.x, TextViewVerticalOffset, self.textView.frame.size.width, TextViewH);
}
- (void)resumeTextViewContentSize {
    
    self.textView.text = self.currentText;
}




#pragma mark -- 计算textViewContentSize改变

- (CGFloat)getTextViewContentH:(XLTextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

- (CGFloat)fontWidth
{
    return 36.f; //16号字体
}

- (CGFloat)maxLines {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat line = 5;
    if (h == 480) {
        line = 3;
    } else if (h == 568){
        line = 3.5;
    } else if (h == 667){
        line = 4;
    } else if (h == 736){
        line = 4.5;
    }
    return line;
}



@end




