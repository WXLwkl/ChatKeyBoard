//
//  MessageInputView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MessageInputView.h"

#import <QuartzCore/QuartzCore.h>
#import "Header.h"
#import "NSString+MessageInputView.h"
#import "ConfigurationHelper.h"




#import "MorePanel.h"




#import "ShareMenuView.h"
#import "EmoticonManagerView.h"


#define TextViewH 36


@interface MessageInputView ()<ChatToolBarDelegate, MorePanelDelegate, EmoticonManagerViewDelegate>

@property (nonatomic, strong) ChatToolBar *chatToolBar;


@property (nonatomic, strong) MorePanel *morePanel;
//@property (nonatomic, strong) ShareMenuView *shareMenuView;
@property (nonatomic, strong) EmoticonManagerView *emoticonManagerView;


/**
 *  是否取消錄音
 */
@property (nonatomic, assign, readwrite) BOOL isCancelled;

/**
 *  是否正在錄音
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property (nonatomic, copy) NSString *inputedText;

/**
 *  记录旧的textView contentSize Heigth
 */
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;



@end

@implementation MessageInputView

/*
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
 */

#pragma mark - life cycle
- (void)dealloc {
    // remove KVO
    [self removeObserver:self forKeyPath:@"self.chatToolBar.frame"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        [self setup];
        [self initSubviews];
    }
    return self;
}

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    // 默认设置
    _allowsSendVoice = YES;
    _allowsSendFace = YES;
    _allowsSendMultiMedia = YES;
    
    _inputViewState = InputViewStateNormal;
    
    _previousTextViewContentHeight = TextViewH;
    
    
}

- (void)initSubviews {
    
    _chatToolBar = [[ChatToolBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kChatToolBarHeight)];
    _chatToolBar.delegate = self;
    [self addSubview:_chatToolBar];
    
    [_chatToolBar setTextViewPlaceHolder:@"发送信息"];
//    [_chatToolBar setTextViewPlaceHolderColor:[UIColor redColor]];
    
    
    [_chatToolBar.voiceBtn addTarget:self action:@selector(onTouchVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_chatToolBar.emoticonBtn addTarget:self action:@selector(onTouchEmoticonBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_chatToolBar.moreBtn addTarget:self action:@selector(onTouchMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_chatToolBar.recordBtn addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_chatToolBar.recordBtn addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [_chatToolBar.recordBtn addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_chatToolBar.recordBtn addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [_chatToolBar.recordBtn addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    
    
    
    
    
    _emoticonManagerView = [[EmoticonManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.chatToolBar.frame), CGRectGetWidth(self.chatToolBar.frame), kbottomCotainerHeight)];
    _emoticonManagerView.delegate = self;
    [self addSubview:_emoticonManagerView];
    
    
    
    
    
    
    
    NSArray *dataArr = @[
                 @{@"name":@"照片", @"imgNor":@"sharemore_pic", @"imgHig":@""},
                 @{@"name":@"拍摄", @"imgNor":@"sharemore_video", @"imgHig":@""},
                 @{@"name":@"位置", @"imgNor":@"sharemore_location", @"imgHig":@""},
                 @{@"name":@"小视频", @"imgNor":@"sharemore_sight", @"imgHig":@""},
                 @{@"name":@"转账", @"imgNor":@"sharemore_pay", @"imgHig":@""},
                 @{@"name":@"个人名片", @"imgNor":@"sharemore_friendcard", @"imgHig":@""},
                 @{@"name":@"语音输入", @"imgNor":@"sharemore_voiceinput", @"imgHig":@""},
                 @{@"name":@"语音", @"imgNor":@"sharemore_wxtalk", @"imgHig":@""},
                 @{@"name":@"收藏", @"imgNor":@"sharemore_myfav", @"imgHig":@""},
                 @{@"name":@"卡券", @"imgNor":@"sharemore_wallet", @"imgHig":@""}
                 ];
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    for (NSDictionary *dic in dataArr) {
        MoreItemModel *shareMenuItem = [[MoreItemModel alloc] initWithNormalIconImage:[UIImage imageNamed:dic[@"imgNor"]] title:dic[@"name"]];
        [shareMenuItems addObject:shareMenuItem];
    }
    
    _morePanel = [[MorePanel alloc] init];
    _morePanel.delegate = self;
    _morePanel.frame = _emoticonManagerView.frame;
    [self addSubview:_morePanel];
    
    _morePanel.shareMenuItems = shareMenuItems;

    

    [self addObserver:self forKeyPath:@"self.chatToolBar.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - setter
- (void)setInputViewState:(InputViewState)inputViewState {
    
    _inputViewState = inputViewState;
    self.chatToolBar.state = inputViewState;
    switch (inputViewState) {
        case InputViewStateText:
        case InputViewStateVoice:
        case InputViewStateNormal: {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.morePanel.hidden = self.emoticonManagerView.hidden = YES;
            });
        }
            break;
        case InputViewStateEmotion: {
            
            [self bringSubviewToFront:self.emoticonManagerView];
            self.morePanel.hidden = YES;
            self.emoticonManagerView.hidden = NO;
        }
            break;
        case InputViewStateShareMenu: {
            
            [self bringSubviewToFront:self.morePanel];
            self.morePanel.hidden = NO;
            self.emoticonManagerView.hidden = YES;
        }
            break;
    }
}


#pragma mark - ChatToolBar - Actions
- (void)onTouchVoiceBtn:(id)sender {
    // image change
    
    
    if (self.inputViewState != InputViewStateVoice) {
//        __weak typeof(self) weakSelf = self;
//        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
//            [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
//                if (granted) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (self.chatToolBar.showsKeyboard) {
                            self.inputViewState = InputViewStateVoice;
                            self.chatToolBar.showsKeyboard = NO;
        
//                        }else{
//                            [self refreshStatus:NIMInputStatusAudio];
//                            [self callDidChangeHeight];
//                        }
//                    });
//                }
//                else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[[UIAlertView alloc] initWithTitle:nil
//                                                    message:@"没有麦克风权限"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil] show];
//                    });
//                }
//            }];
//        }
    } else {
        
        self.inputViewState = InputViewStateText;
        self.chatToolBar.showsKeyboard = YES;
        
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
        [self.delegate didChangeSendVoiceAction:!self.chatToolBar.showsKeyboard];
    }
}

- (void)onTouchEmoticonBtn:(id)sender {
    
    if (self.inputViewState != InputViewStateEmotion) {
    
//        if (self.chatToolBar.showsKeyboard) {
            self.inputViewState = InputViewStateEmotion;
            self.chatToolBar.showsKeyboard = NO;
//        } else {
//            [self refreshStatus:NIMInputStatusEmoticon];
//            [self callDidChangeHeight];
//        }
        
    } else {
        self.inputViewState = InputViewStateText;
        self.chatToolBar.showsKeyboard = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedFaceAction:)]) {
        [self.delegate didSelectedFaceAction:!self.chatToolBar.showsKeyboard];
    }
}
- (void)onTouchMoreBtn:(id)sender {
    if (self.inputViewState != InputViewStateShareMenu) {
        
//        if (self.chatToolBar.showsKeyboard) {
            self.inputViewState = InputViewStateShareMenu;
            self.chatToolBar.showsKeyboard = NO;
//        } else {
//            [self refreshStatus:NIMInputStatusMore];
//            [self callDidChangeHeight];
//        }
    }
    else
    {
        self.inputViewState = InputViewStateText;
        self.chatToolBar.showsKeyboard = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
        [self.delegate didSelectedMultipleMediaAction:!self.chatToolBar.showsKeyboard];
    }
}


/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown {
    self.isCancelled = NO;
    self.isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(prepareRecordingVoiceActionWithCompletion:)]) {
        WEAKSELF
        //这边回调 return 的 YES 或者 NO, 可以让底层知道该次录音是否成功，进而处理无用的 record 对象
        [self.delegate prepareRecordingVoiceActionWithCompletion:^BOOL{
            STRONGSELF
            //这边要判断回调回来的时候，使用者是不是已经早就松开手了
            if (strongSelf && !strongSelf.isCancelled) {
                strongSelf.isRecording = YES;
                [strongSelf.delegate didStartRecordingVoiceAction];
                return YES;
            } else {
                return NO;
            }
        }];
    }
}
/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside {
    //如果已經開始錄音了, 才需要做取消的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
            [self.delegate didCancelRecordingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside {
    //如果已經開始錄音了, 才需要做結束的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
            [self.delegate didFinishRecoingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}
/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
- (void)holdDownDragOutside {
    //如果已經開始錄音了, 才需要做拖曳出去的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
            [self.delegate didDragOutsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}
/**
 *  当手指滑动到录音按钮的范围之内所触发的时间
 */
- (void)holdDownDragInside {
    //如果已經開始錄音了, 才需要做拖曳回來的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
            [self.delegate didDragInsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}
#pragma mark - MorePanelDelegate
- (void)didSelecteShareMenuItem:(MoreItemModel *)moreItem atIndex:(NSInteger)index {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputView:didSelecteShareMenuItem:atIndex:)]) {
        [self.delegate messageInputView:self didSelecteShareMenuItem:moreItem atIndex:index];
    }
    
}

#pragma mark - ChatToolBarDelegate

- (void)chatToolBarTextViewWillBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:textView];
    }
}
- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:textView];
    }
}
- (void)chatToolBarTextViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:textView];
    }
}

- (void)chatToolBarSendText:(NSString *)text {
    
    if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
        [self.delegate didSendTextAction:text];
    }
    [self.chatToolBar clearTextViewContent];
}
#pragma mark - EmoticonManagerViewDelegate

- (void)didPressSend:(id)sender {
    
    NSString *text = self.chatToolBar.contentText;
    if (text.length <= 0) {
        NSLog(@"内容是空的，发送无效");
        return;
    }
    [self.chatToolBar clearTextViewContent];
    
    if ([self.delegate respondsToSelector:@selector(messageInputView:didPressSend:)]) {
        [self.delegate messageInputView:self didPressSend:text];
    }
    
}
- (void)selectedEmoticon:(NSString *)emoticonID catalog:(NSString *)emotCatalogID description:(NSString *)description {
    
    if (!emotCatalogID) { //删除键
        [self onTextDelete];
    }else{
        if ([emotCatalogID isEqualToString:NIMKit_EmojiCatalog]) {
            [self.chatToolBar insertText:description];
        }else{
            //发送贴图消息
//            if ([self.actionDelegate respondsToSelector:@selector(onSelectChartlet:catalog:)]) {
//                [self.actionDelegate onSelectChartlet:emoticonID catalog:emotCatalogID];
//            }
            if ([self.delegate respondsToSelector:@selector(messageInputView:didSelectChartlet:catalog:)]) {
                [self.delegate messageInputView:self didSelectChartlet:emoticonID catalog:emotCatalogID];
            }
        }
        
        
    }
}
- (BOOL)onTextDelete {
    
    
    NSRange range = [self delRangeForEmoticon];
    
//    关于 @ 删除
//    if (range.length == 1) {
////        删的不是表情，可能是@
////        InputAtItem *item = [self delRangeForAt];
////        if (item) {
////            range = item.range;
////        }
//    }
//    if (range.length == 1) {
//        //自动删除
//        return YES;
//    }
    
    [self.chatToolBar deleteText:range];
    return NO;
}


- (NSRange)delRangeForEmoticon {
    
    NSString *text = self.chatToolBar.contentText;
    NSRange range = [self rangeForPrefix:@"[" suffix:@"]"];
    NSRange selectedRange = [self.chatToolBar selectedRange];
    
    
    if (range.length > 1) {
        NSString *name = [text substringWithRange:range];
        InputEmoticon *icon = [[EmoticonManager sharedManager] emoticonByTag:name];
        range = icon? range : NSMakeRange(selectedRange.location - 1, 1);
    }
    return range;
}
- (NSRange)rangeForPrefix:(NSString *)prefix suffix:(NSString *)suffix {
    NSString *text = self.chatToolBar.contentText;
    NSRange range = [self.chatToolBar selectedRange];
    NSString *selectedText = range.length ? [text substringWithRange:range] : text;
    NSInteger endLocation = range.location;
    if (endLocation <= 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSInteger index = -1;
    if ([selectedText hasSuffix:suffix]) {
        //往前搜最多20个字符，一般来讲是够了...
        NSInteger p = 20;
        for (NSInteger i = endLocation; i >= endLocation - p && i-1 >= 0 ; i--) {
            NSRange subRange = NSMakeRange(i - 1, 1);
            NSString *subString = [text substringWithRange:subRange];
            if ([subString compare:prefix] == NSOrderedSame) {
                index = i - 1;
                break;
            }
        }
    }
    return index == -1 ? NSMakeRange(endLocation - 1, 1) : NSMakeRange(index, endLocation - index);
}

#pragma mark - Key-value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if (object == self && [keyPath isEqualToString:@"self.chatToolBar.frame"]) {
        
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGFloat changeHeight = newRect.size.height - oldRect.size.height;
        
        self.frame = CGRectMake(0, self.frame.origin.y - changeHeight, self.frame.size.width, self.frame.size.height + changeHeight);
        
        self.emoticonManagerView.frame = CGRectMake(0, CGRectGetMaxY(self.chatToolBar.frame), CGRectGetWidth(self.chatToolBar.frame), self.frame.size.height - CGRectGetMaxY(self.chatToolBar.frame));
        self.morePanel.frame = self.emoticonManagerView.frame;
        
    }
}

@end
