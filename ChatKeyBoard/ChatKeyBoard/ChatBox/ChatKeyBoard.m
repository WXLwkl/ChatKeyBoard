//
//  ChatKeyBoard.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//
#import "Header.h"
#import "ChatKeyBoard.h"

#import "ChatToolBar.h"
#import "FacePanel.h"
#import "MorePanel.h"
#import "OfficialAccountToolbar.h"

#import "ChatToolBarItemModel.h"
#import "FaceSubjectModel.h"
#import "MoreItemModel.h"

CGFloat getSupviewH(CGRect frame) {
    return frame.origin.y + kChatToolBarHeight;
}

CGFloat getDifferenceH(CGRect frame) {
    return kScreenHeight - (frame.origin.y + kChatToolBarHeight);
}

@interface ChatKeyBoard ()<ChatToolBarDelegate>


@property (nonatomic, strong) ChatToolBar *chatToolBar;
@property (nonatomic, strong) FacePanel *facePanel;
@property (nonatomic, strong) MorePanel *morePanel;
@property (nonatomic, strong) OfficialAccountToolbar *OAtoolbar;

//@property (nonatomic, strong) ChatToolBar *chatToolBar;
//@property (nonatomic, strong) FacePanel *facePanel;
//@property (nonatomic, strong) MorePanel *morePanel;
//@property (nonatomic, strong) OfficialAccountToolbar *OAtoolbar;

@property (nonatomic, assign) BOOL translucent;

@property (nonatomic, assign) CGRect keyboardInitialFrame;

@end


@implementation ChatKeyBoard

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self removeObserver:self forKeyPath:@"self.chatToolBar.frame"];
}

+ (instancetype)keyBoard {
    return [self keyBoardWithNavgationBarTranslucent:YES];
}

+ (instancetype)keyBoardWithNavgationBarTranslucent:(BOOL)translucent {
    CGRect frame = CGRectZero;
    
    if (translucent) {
        frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight, kScreenWidth, kChatKeyBoardHeight);
    }else {
        frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight - 64, kScreenWidth, kChatKeyBoardHeight);
    }
    return [[self alloc] initWithFrame:frame];
}

+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds {
    CGRect frame = CGRectMake(0, bounds.size.height - kChatToolBarHeight, kScreenWidth, kChatKeyBoardHeight);
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _keyboardInitialFrame = frame;
        
        _chatToolBar = [[ChatToolBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kChatToolBarHeight)];
        _chatToolBar.delegate = self;
        [self addSubview:self.chatToolBar];
        
        _facePanel = [[FacePanel alloc] initWithFrame:CGRectMake(0, kChatKeyBoardHeight - kFacePanelHeight, kScreenWidth, kScreenHeight)];
#warning 代理方法未实现
//        _facePanel.delegate = self;
        [self addSubview:self.facePanel];
        _morePanel = [[MorePanel alloc] initWithFrame:self.facePanel.frame];
#warning 代理方法未实现
//        _morePanel.delegate = self;
        [self addSubview:self.morePanel];
        
        _OAtoolbar = [[OfficialAccountToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), kScreenWidth, kChatToolBarHeight)];
        [self addSubview:self.OAtoolbar];
        
        __weak __typeof(self) weakSelf = self;
        self.OAtoolbar.switchAction = ^{
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.OAtoolbar.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.frame), CGRectGetWidth(weakSelf.frame), kChatToolBarHeight);
                CGFloat y = weakSelf.frame.origin.y;
                y = getSupviewH(self.keyboardInitialFrame) - self.chatToolBar.frame.size.height;
                weakSelf.frame = CGRectMake(0, y, weakSelf.frame.size.width, weakSelf.frame.size.height);
            }];
        };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self addObserver:self forKeyPath:@"self.chatToolBar.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
    }
    return self;
}
#pragma mark -- 跟随键盘的坐标变化
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    // 键盘已经弹起时，表情按钮被选择
    if (self.chatToolBar.faceSelected && (getSupviewH(self.keyboardInitialFrame) - CGRectGetMidX(self.frame)) < CGRectGetHeight(self.frame)) {
        [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.morePanel.hidden = YES;
            self.facePanel.hidden = NO;
            self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame) - CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.morePanel.frame = self.facePanel.frame;
        } completion:nil];
    } else if (self.chatToolBar.moreFuncSelected && (getSupviewH(self.keyboardInitialFrame) - CGRectGetMidY(self.frame)) < CGRectGetHeight(self.frame)) {
        // 键盘已经弹起时，more按钮被选择
        [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.morePanel.hidden = NO;
            self.facePanel.hidden = YES;
            self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame) - CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.morePanel.frame = self.morePanel.frame;
        } completion:nil];
    } else if (self.chatToolBar.voiceSelected && !self.chatToolBar.textView.isFirstResponder) {
        //语音按钮被选择，且textview并不是第一响应者
        [UIView animateWithDuration:0.25 animations:^{
            self.morePanel.hidden = YES;
            self.facePanel.hidden = YES;
            self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame)-CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            
            CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            
            CGFloat targetY = end.origin.y - (CGRectGetHeight(self.frame) - kMorePanelHeight) - getDifferenceH(self.keyboardInitialFrame);
            
            if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)) {
                // 键盘弹起 (包括，第三方键盘回调三次问题，监听仅执行最后一次)
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
                self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
                
            } else if (end.origin.y == kScreenHeight && begin.origin.y!=end.origin.y && duration > 0) {
                //键盘收起
                if (self.keyBoardStyle == KeyBoardStyleChat) {
                    
                    self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                    
                } else if (self.keyBoardStyle == KeyBoardStyleComment) {
                    if (self.chatToolBar.voiceSelected) {
                        self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                    } else {
                        self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame), CGRectGetWidth(self.frame), self.frame.size.height);
                    }
                }
            } else if ((begin.origin.y-end.origin.y<0) && duration == 0) {
                //键盘切换
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
            }
        }];
    }
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"self.chatToolBar.frame"]) {
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGFloat changeHeight = newRect.size.height - oldRect.size.height;
        self.frame = CGRectMake(0, self.frame.origin.y - changeHeight, self.frame.size.width, self.frame.size.height + changeHeight);
        self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
        self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kMorePanelHeight, CGRectGetWidth(self.frame), kMorePanelHeight);
        self.OAtoolbar.frame = CGRectMake(0, CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), kChatToolBarHeight);
    }
}

#pragma mark -- ChatToolBarDelegate
- (void)chatToolBar:(ChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change {
    if (select && change == NO) {
        [UIView animateWithDuration:0.25 animations:^{
            CGFloat y = self.frame.origin.y;
            y = getSupviewH(self.keyboardInitialFrame) - self.chatToolBar.frame.size.height;
            self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
        }];
    }
}
- (void)chatToolBar:(ChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change {
    
    if (select && change == NO) {
        self.morePanel.hidden = YES;
        self.facePanel.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame)-CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
        }];
    }
}
- (void)chatToolBar:(ChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change {
    
    if (select && change == NO) {
        self.morePanel.hidden = NO;
        self.facePanel.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame)-CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kMorePanelHeight, CGRectGetWidth(self.frame), kMorePanelHeight);
            self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
        }];
    }
}
- (void)chatToolBarSwitchToolBarBtnPressed:(ChatToolBar *)toolBar keyBoardState:(BOOL)change {
    if (change == NO) {
        [UIView animateWithDuration:0.25 animations:^{
            CGFloat y = self.frame.origin.y;
            y = getSupviewH(self.keyboardInitialFrame) - kChatToolBarHeight;
            self.frame = CGRectMake(0,getSupviewH(self.keyboardInitialFrame), self.frame.size.width, self.frame.size.height);
            self.OAtoolbar.frame = CGRectMake(0, 0, self.frame.size.width, kChatToolBarHeight);
            self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
        }];
    } else {
        CGFloat y = getSupviewH(self.keyboardInitialFrame) - kChatToolBarHeight;
        self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame), self.frame.size.width, self.frame.size.height);
        self.OAtoolbar.frame = CGRectMake(0, 0, self.frame.size.width, kChatToolBarHeight);
        self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
    }
}

- (void)chatToolBarDidStartRecording:(ChatToolBar *)toolBar {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardDidStartRecording:)]) {
        [self.delegate chatKeyBoardDidStartRecording:self];
    }
}
- (void)chatToolBarDidCancelRecording:(ChatToolBar *)toolBar {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardDidCancelRecording:)]) {
        [self.delegate chatKeyBoardDidCancelRecording:self];
    }
}
- (void)chatToolBarDidFinishRecoding:(ChatToolBar *)toolBar {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardDidFinishRecoding:)]) {
        [self.delegate chatKeyBoardDidFinishRecoding:self];
    }
}
- (void)chatToolBarWillCancelRecoding:(ChatToolBar *)toolBar {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardWillCancelRecoding:)]) {
        [self.delegate chatKeyBoardWillCancelRecoding:self];
    }
}
- (void)chatToolBarContineRecording:(ChatToolBar *)toolBar {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardContineRecording:)]) {
        [self.delegate chatKeyBoardContineRecording:self];
    }
}

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardTextViewDidBeginEditing:)]) {
        [self.delegate chatKeyBoardTextViewDidBeginEditing:textView];
    }
}
- (void)chatToolBarTextViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardTextViewDidChange:)]) {
        [self.delegate chatKeyBoardTextViewDidChange:textView];
    }
}
- (void)chatToolBarSendText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardSendText:)]) {
        [self.delegate chatKeyBoardSendText:text];
    }
    [self.chatToolBar clearTextViewContent];
}

#pragma mark -- dataSource
- (void)setDataSource:(id<ChatKeyBoardDataSource>)dataSource {
    _dataSource = dataSource;
    if (dataSource == nil) {
        return;
    }
    if ([self.dataSource respondsToSelector:@selector(chatKeyBoardToolbarItems)]) {
        NSArray<ChatToolBarItemModel *> *barItemsModels = [self.dataSource chatKeyBoardToolbarItems];
        [self.chatToolBar loadBarItems:barItemsModels];
    }
    if ([self.dataSource respondsToSelector:@selector(chatKeyBoardMorePanelItems)]) {
        NSArray<MoreItemModel *> *moreItems = [self.dataSource chatKeyBoardMorePanelItems];
        [self.morePanel loadMoreItems:moreItems];
    }
    
    if ([self.dataSource respondsToSelector:@selector(chatKeyBoardFacePanelSubjectItems)]) {
        NSArray<FaceSubjectModel *> *subjectMItems = [self.dataSource chatKeyBoardFacePanelSubjectItems];
        [self.facePanel loadFaceSubjectItems:subjectMItems];
    }
}

#pragma mark - setter
- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    [self.chatToolBar setTextViewPlaceHolder:placeHolder];
}
- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    [self.chatToolBar setTextViewPlaceHolderColor:placeHolderColor];
}
- (void)setAllowVoice:(BOOL)allowVoice {
    self.chatToolBar.allowVoice = allowVoice;
}
- (void)setAllowFace:(BOOL)allowFace {
    self.chatToolBar.allowFace = allowFace;
}
- (void)setAllowMore:(BOOL)allowMore {
    self.chatToolBar.allowMoreFunc = allowMore;
}
- (void)setAllowSwitchBar:(BOOL)allowSwitchBar {
    self.chatToolBar.allowSwitchBar = allowSwitchBar;
}
- (void)setKeyBoardStyle:(KeyBoardStyle)keyBoardStyle {
    _keyBoardStyle = keyBoardStyle;
    if (keyBoardStyle == KeyBoardStyleComment) {
        self.frame = CGRectMake(0, self.frame.origin.y + kChatToolBarHeight, self.frame.size.width, self.frame.size.height);
    }
}
- (void)beginComment {
    if (self.keyBoardStyle != KeyBoardStyleComment) {
        NSException *excep = [NSException exceptionWithName:@"ChatKeyBoardException" reason:@"键盘未开启评论风格" userInfo:nil];
        [excep raise];
    }
    [self.chatToolBar prepareForBeginComment];
    [self.chatToolBar.textView becomeFirstResponder];
}
- (void)endComment {
    if (self.keyBoardStyle != KeyBoardStyleComment) {
        NSException *excep = [NSException exceptionWithName:@"ChatKeyBoardException" reason:@"键盘未开启评论风格" userInfo:nil];
        [excep raise];
    }
    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        [self.chatToolBar prepareForEndComment];
        self.frame = CGRectMake(0, getSupviewH(self.keyboardInitialFrame), self.frame.size.width, CGRectGetHeight(self.frame));
    } completion:nil];
}

@end
