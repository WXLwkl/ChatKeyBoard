//
//  ChatToolBar.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "ChatToolBar.h"
#import "Header.h"
//#import "ChatToolBarItemModel.h"

#define Image(str)              (str == nil || str.length == 0) ? nil : [UIImage imageNamed:str]
#define ItemW                   44                  //44
#define ItemH                   kChatToolBarHeight  //49
#define TextViewH               36
#define TextViewVerticalOffset  (ItemH-TextViewH)/2.0


@interface ChatToolBar ()<UITextViewDelegate>

@property CGFloat previousTextViewHeight;


/** 输入文本框 */
@property (nonatomic, strong) XLTextView *textView;


@end

@implementation ChatToolBar

- (NSRange)selectedRange {
    return self.textView.selectedRange;
}
//- (NSString *)contentText {
//    return self.textView.text;
//}

//- (void)setContentText:(NSString *)contentText {
//    
//    self.textView.text = contentText;
//}

#pragma mark -- dealloc

- (void)dealloc {
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
    self.previousTextViewHeight = TextViewH;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:215.0/255.0 green:215/255.0 blue:217/255.0 alpha:1.0].CGColor;
    
    [self addSubview:self.voiceBtn];
    [self addSubview:self.emoticonBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.switchBarBtn];
    [self addSubview:self.textView];
    [self addSubview:self.recordBtn];
    
    //KVO
    [self addObserver:self forKeyPath:@"self.textView.contentSize" options:(NSKeyValueObservingOptionNew) context:nil];
    
}

- (void)layoutSubviews {
    
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
        self.emoticonBtn.frame = CGRectMake(self.frame.size.width - CGRectGetWidth(self.moreBtn.frame) - ItemW, barViewH- ItemH, ItemW, ItemH);
    } else {
        self.emoticonBtn.frame = CGRectZero;
    }
    self.textView.frame = CGRectMake(CGRectGetWidth(self.switchBarBtn.frame) + CGRectGetWidth(self.voiceBtn.frame), TextViewVerticalOffset, self.frame.size.width-CGRectGetWidth(self.switchBarBtn.frame)-CGRectGetWidth(self.voiceBtn.frame)-CGRectGetWidth(self.emoticonBtn.frame)-CGRectGetWidth(self.moreBtn.frame), self.textView.frame.size.height);
    
    self.recordBtn.frame = self.textView.frame;
}

#pragma mark - 对外接口
- (void)insertText:(NSString *)text {
    NSRange range = self.textView.selectedRange;
    NSString *replaceText = [self.textView.text stringByReplacingCharactersInRange:range withString:text];
    range = NSMakeRange(range.location + text.length, 0);
    self.contentText = self.textView.text = replaceText;
    self.textView.selectedRange = range;
}
- (void)deleteText:(NSRange)range {
    NSString *text = self.contentText;
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound && range.length != 0) {
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        self.contentText = self.textView.text = newText;
        self.textView.selectedRange = newSelectRange;
    }
}

- (void)clearTextViewContent {
    self.contentText = self.textView.text = @"";
}


#pragma mark - 站位符
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

#pragma mark -- UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.emoticonBtn.selected = self.voiceBtn.selected = self.moreBtn.selected = NO;
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewWillBeginEditing:)]) {
        [self.delegate chatToolBarTextViewWillBeginEditing:self.textView];
    }
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
            
            [self.delegate chatToolBarSendText:textView.text];
            self.contentText = @"";
        }
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.contentText = textView.text;
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDidChange:)]) {
        [self.delegate chatToolBarTextViewDidChange:self.textView];
    }
}

#pragma mark - kvo
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
            CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
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
#pragma mark -- 计算textViewContentSize改变

- (CGFloat)getTextViewContentH:(XLTextView *)textView {
   
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}

- (CGFloat)fontWidth {
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


- (void)adjustTextViewContentSize {
    //调整textView和recordBtn的frame
    self.contentText = self.textView.text;
    self.textView.text = @"";
    self.textView.contentSize = CGSizeMake(CGRectGetWidth(self.textView.frame), TextViewH);
    self.recordBtn.frame = CGRectMake(self.textView.frame.origin.x, TextViewVerticalOffset, self.textView.frame.size.width, TextViewH);
}

- (void)resumeTextViewContentSize {
    
    self.textView.text = self.contentText;
}
#pragma mark - Keyboard
- (void)setShowsKeyboard:(BOOL)showsKeyboard {
    if (showsKeyboard) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textView resignFirstResponder];
    }
}

- (BOOL)showsKeyboard {
    return [self.textView isFirstResponder];
}


#pragma mark - setter
- (void)setState:(InputViewState)state {
    
    _state = state;
    
    switch (state) {
        case InputViewStateNormal: {
            self.voiceBtn.selected = !self.voiceBtn.selected;
            
            self.voiceBtn.selected = self.emoticonBtn.selected = self.moreBtn.selected = self.textView.hidden = NO;
            self.recordBtn.hidden = YES;
            [self resumeTextViewContentSize];
            break;
        }
        case InputViewStateText: {
            
            self.voiceBtn.selected = self.emoticonBtn.selected = self.moreBtn.selected = self.textView.hidden = NO;
            self.recordBtn.hidden = YES;
            [self resumeTextViewContentSize];
            break;
        }
        case InputViewStateVoice: {
            
            self.voiceBtn.selected = self.textView.hidden = YES;
            self.emoticonBtn.selected = self.moreBtn.selected = self.recordBtn.hidden = NO;
            [self adjustTextViewContentSize];
            break;
        }
        case InputViewStateEmotion: {
            
            self.voiceBtn.selected = self.moreBtn.selected = self.textView.hidden = NO;
            self.emoticonBtn.selected = self.recordBtn.hidden = YES;
            [self resumeTextViewContentSize];
            break;
        }
        case InputViewStateShareMenu: {
            self.voiceBtn.selected = self.emoticonBtn.selected = self.textView.hidden = NO;
            self.moreBtn.selected = self.recordBtn.hidden = YES;
            [self resumeTextViewContentSize];
            break;
        }
    }
}
- (void)setAllowSwitchBar:(BOOL)allowSwitchBar {
    _allowSwitchBar = allowSwitchBar;
    
    self.switchBarBtn.hidden = !_allowSwitchBar;
    [self setNeedsLayout];
}

- (void)setAllowVoice:(BOOL)allowVoice {
    
    _allowVoice = allowVoice;
    
    self.voiceBtn.hidden = !_allowVoice;
    [self setNeedsLayout];
}
- (void)setAllowFace:(BOOL)allowFace {
    _allowFace = allowFace;
    
    self.emoticonBtn.hidden = !_allowFace;
    [self setNeedsLayout];
}
- (void)setAllowMoreFunc:(BOOL)allowMoreFunc {
    
    _allowMoreFunc = allowMoreFunc;
    
    self.moreBtn.hidden = !_allowMoreFunc;
    [self setNeedsLayout];
}

#pragma mark - lazy

- (UIButton *)switchBarBtn {
    if (!_switchBarBtn) {
        _switchBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchBarBtn.hidden = YES;
        _switchBarBtn.tag = 1;
        [_switchBarBtn setImage:Image(@"switchDown") forState:UIControlStateNormal];
        _switchBarBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _switchBarBtn;
}

- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.tag = 2;
        [_voiceBtn setImage:Image(@"voice") forState:UIControlStateNormal];
        [_voiceBtn setImage:Image(@"keyboard") forState:UIControlStateSelected];
        [_voiceBtn setImage:Image(@"voice_HL") forState:UIControlStateHighlighted];
        _voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _voiceBtn;
}
- (XLTextView *)textView {
    if (!_textView) {
        _textView = [[XLTextView alloc] init];
        _textView.frame = CGRectMake(0, 0, 0, TextViewH);
        _textView.delegate = self;
    }
    return _textView;
}
- (UIButton *)emoticonBtn {
    if (!_emoticonBtn) {
        _emoticonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emoticonBtn.tag = 3;
        [_emoticonBtn setImage:Image(@"face") forState:UIControlStateNormal];
        [_emoticonBtn setImage:Image(@"keyboard") forState:UIControlStateSelected];
        [_emoticonBtn setImage:Image(@"face_HL") forState:UIControlStateHighlighted];
        _emoticonBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _emoticonBtn;
}
- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.tag = 4;
        [_moreBtn setImage:Image(@"more_ios") forState:UIControlStateNormal];
        [_moreBtn setImage:Image(@"more_ios_HL") forState:UIControlStateHighlighted];
        _moreBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _moreBtn;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [[UIButton alloc] init];
       
        _recordBtn.layer.cornerRadius = 5.0f;
        _recordBtn.layer.borderWidth = 0.5;
        _recordBtn.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
        [_recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_recordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _recordBtn.hidden = YES;
    }
    return _recordBtn;
}
@end
