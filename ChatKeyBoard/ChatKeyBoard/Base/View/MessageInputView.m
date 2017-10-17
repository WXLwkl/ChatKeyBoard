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



@interface MessageInputView ()<UITextViewDelegate>

@property (nonatomic, weak, readwrite) MessageTextView *inputTextView;

@property (nonatomic, weak, readwrite) UIButton *voiceChangeButton;

@property (nonatomic, weak, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, weak, readwrite) UIButton *faceSendButton;

@property (nonatomic, weak, readwrite) UIButton *holdDownButton;


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
 *  输入框内的所有按钮，点击事件所触发的方法
 *
 *  @param sender 被点击的按钮对象
 */
- (void)messageStyleButtonClicked:(UIButton *)sender;

/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown;

/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside;

/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside;

/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
- (void)holdDownDragOutside;

/**
 *  当手指滑动到录音按钮的范围之内所触发的时间
 */
- (void)holdDownDragInside;

#pragma mark - layout subViews UI
/**
 *  根据正常显示和高亮状态创建一个按钮对象
 *
 *  @param image   正常显示图
 *  @param hlImage 高亮显示图
 *
 *  @return 返回按钮对象
 */
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage ;

/**
 *  根据输入框的样式类型配置输入框的样式和UI布局
 *
 *  @param style 输入框样式类型
 */
- (void)setupMessageInputViewBarWithStyle:(MessageInputViewStyle)style;

/**
 *  配置默认参数
 */
- (void)setup ;

#pragma mark - Message input view
/**
 *  动态改变textView的高度
 *
 *  @param changeInHeight 动态的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

@end

@implementation MessageInputView


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

#pragma mark - life cycle
- (void)dealloc {
    _inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self setup];
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
    
    _messageInputViewStyle = MessageInputViewStyleFlat;
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle:self.messageInputViewStyle];
    }
}
- (void)setupMessageInputViewBarWithStyle:(MessageInputViewStyle)style {
    //配置输入工具条的样式和布局
    //需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0f;
    //水平间隔
    CGFloat horizontalPadding = 8;
    
    //竖直间隔
    CGFloat verticalPadding = (kChatToolBarHeight - [MessageInputView textViewLineHeight]) /2.0f;
    
    //输入框
    CGFloat textViewLeftMargin = (style == MessageInputViewStyleFlat) ? 6.0 : 4.0;
    
    //每个按钮统一使用的frame变量
    CGRect buttonFrame;
    //按钮对象消息
    UIButton *button;
    
    //允许发送语音
    if (self.allowsSendVoice) {
        NSString *voiceNormalImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewVoiceNormalImageNameKey];
        if (!voiceNormalImageName) {
            voiceNormalImageName = @"voice";
        }
        NSString *voiceHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewVoiceHLImageNameKey];
        if (!voiceHLImageName) {
            voiceHLImageName = @"voice_HL";
        }
        NSString *keyboardNormalImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewKeyboardNormalImageNameKey];
        if (!keyboardNormalImageName) {
            keyboardNormalImageName = @"keyboard";
        }
        NSString *keyboardHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewKeyboardHLImageNameKey];
        if (!keyboardHLImageName) {
            keyboardHLImageName = @"keyboard_HL";
        }
        
        button = [self createButtonWithImage:[UIImage imageNamed:voiceNormalImageName] HLImage:[UIImage imageNamed:voiceHLImageName]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        [button setBackgroundImage:[UIImage imageNamed:keyboardNormalImageName] forState:UIControlStateSelected];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        
        allButtonWidth += CGRectGetMaxX(buttonFrame);
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        
        self.voiceChangeButton = button;
    }
    //允许发送多媒体消息，为什么不先放表情按钮呢，因为表情按钮要根据 +号 按钮布局
    if (self.allowsSendMultiMedia) {
        NSString *extensionNormalImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewExtensionNormalImageNameKey];
        if (!extensionNormalImageName) {
            extensionNormalImageName = @"multiMedia";
        }
        NSString *extensionHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewExtensionHLImageNameKey];
        if (!extensionHLImageName) {
            extensionHLImageName = @"multiMedia_HL";
        }
        
        button = [self createButtonWithImage:[UIImage imageNamed:extensionNormalImageName] HLImage:[UIImage imageNamed:extensionHLImageName]];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        
        self.multiMediaSendButton = button;
 
    }
    //允许发送表情
    if (self.allowsSendFace) {
        NSString *emotionNormalImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewEmotionNormalImageNameKey];
        if (!emotionNormalImageName) {
            emotionNormalImageName = @"face";
        }
        NSString *emotionHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewEmotionHLImageNameKey];
        if (!emotionHLImageName) {
            emotionHLImageName = @"face_HL";
        }
        
        NSString *keyboardNormalImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewKeyboardNormalImageNameKey];
        if (!keyboardNormalImageName) {
            keyboardNormalImageName = @"keyboard";
        }
        NSString *keyboardHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewKeyboardHLImageNameKey];
        if (!keyboardHLImageName) {
            keyboardHLImageName = @"keyboard_HL";
        }
        
        button = [self createButtonWithImage:[UIImage imageNamed:emotionNormalImageName] HLImage:[UIImage imageNamed:emotionHLImageName]];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:keyboardNormalImageName] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        if (self.allowsSendMultiMedia) {
            buttonFrame.origin = CGPointMake(CGRectGetMinX(self.multiMediaSendButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 1.5;
        } else {
            buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        }
        button.frame = buttonFrame;
        [self addSubview:button];
        
        self.faceSendButton = button;
    }
    
    //输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    CGFloat height = [MessageInputView textViewLineHeight];
    //初始化输入框
    MessageTextView *textView = [[MessageTextView alloc] initWithFrame:CGRectZero];
    //这个是放微信的一个细节体现
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;//UITextView内部判断send按钮是否可以用
    UIColor *placeHolderTextColor = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewPlaceHolderTextColorKey];
    if (placeHolderTextColor) {
        textView.placeHolderTextColor = placeHolderTextColor;
    }
    NSString *placeHolder = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewPlaceHolderKey];
    if (!placeHolder) {
        placeHolder = NSLocalizedStringFromTable(@"SendAMessage", @"MessageDisplayKitString", nil);
    }
    UIColor *textColor = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewTextColorKey];
    if (textColor) {
        textView.textColor = textColor;
    }
    textView.placeHolder = placeHolder;
    textView.delegate = self;
    
    [self addSubview:textView];
    _inputTextView = textView;
    
    //配置不同iOS SDK版本的样式
    switch (style) {
        case MessageInputViewStyleFlat: {
            UIColor *inputBackgroundColor = [ConfigurationHelper appearance].messageInputViewStyle[kXHMessageInputViewBackgroundColorKey];
            NSString *inputViewBackgroundImageName = nil;
            if (!inputBackgroundColor) {
                inputViewBackgroundImageName = [ConfigurationHelper appearance].messageInputViewStyle[kXHMessageInputViewBackgroundImageNameKey];
                if (!inputViewBackgroundImageName) {
                    inputViewBackgroundImageName = @"input-bar-flat";
                }
            }
            UIColor *borderColor = [ConfigurationHelper appearance].messageInputViewStyle[kXHMessageInputViewBorderColorKey];
            if (!borderColor) {
                borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
            }
            CGFloat borderWidth = [[[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewBorderWidthKey] floatValue];
            if (borderWidth == 0) {
                borderWidth = 0.65f;
            }
            CGFloat cornerRadius = [[[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewCornerRadiusKey] floatValue];
            if (cornerRadius == 0) {
                cornerRadius = 6.0f;
            }
            _inputTextView.frame = CGRectMake(textViewLeftMargin, (kChatToolBarHeight-height)/2.0, width, height);
            _inputTextView.backgroundColor = [UIColor clearColor];
            _inputTextView.layer.borderColor = borderColor.CGColor;
            _inputTextView.layer.borderWidth = borderWidth;
            _inputTextView.layer.cornerRadius = cornerRadius;
            
            if (inputBackgroundColor) {
                self.backgroundColor = inputBackgroundColor;
            } else {
                self.image = [[UIImage imageNamed:inputViewBackgroundImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)  resizingMode:UIImageResizingModeTile];
            }
        }
            break;
            
        default:
            break;
    }
    // 如果是可以发送语音的，那就需要一个按钮录音的按钮，事件可以在外部添加
    if (self.allowsSendVoice) {
        NSString *voiceHolderImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewVoiceHolderImageNameKey];
        if (!voiceHolderImageName) {
            voiceHolderImageName = @"VoiceBtn_Black";
        }
        NSString *voiceHolderHLImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageInputViewVoiceHolderHLImageNameKey];
        if (!voiceHolderHLImageName) {
            voiceHolderHLImageName = @"VoiceBtn_BlackHL";
        }
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        button = [self createButtonWithImage:XL_STRETCH_IMAGE([UIImage imageNamed:voiceHolderImageName], edgeInsets) HLImage:XL_STRETCH_IMAGE([UIImage imageNamed:voiceHolderHLImageName], edgeInsets)];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"HoldToTalk", @"MessageDisplayKitString", nil) forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"ReleaseToSend", @"MessageDisplayKitString", nil)  forState:UIControlStateHighlighted];
        buttonFrame = CGRectMake(textViewLeftMargin-5, 0, width+10, self.frame.size.height);
        button.frame = buttonFrame;
        button.alpha = self.voiceChangeButton.selected;
        [button addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
        [self addSubview:button];
        self.holdDownButton = button;
    }    
}


#pragma mark - ButtonAction
- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                self.inputedText = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self.inputTextView resignFirstResponder];
            } else {
                self.inputTextView.text = self.inputedText;
                self.inputedText = nil;
                [self.inputTextView becomeFirstResponder];
            }
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.alpha = sender.selected;
                self.inputTextView.alpha = !sender.selected;
            } completion:nil];
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
        }
            break;
        case 1: {
            sender.selected = !sender.selected;
            self.voiceChangeButton.selected = !sender.selected;
            if (!sender.selected) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = sender.selected;
                    self.inputTextView.alpha = !sender.selected;
                } completion:nil];
            } else {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = !sender.selected;
                    self.inputTextView.alpha = sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
        }
            break;
        case 2: {
            self.faceSendButton.selected = NO;
            self.voiceChangeButton.selected = NO;
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                [self.delegate didSelectedMultipleMediaAction];
            }
        }
            break;
        default:
            break;
    }
}
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

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText], [self.inputTextView.text numberOfLines]);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width, prevFrame.size.height + changeInHeight);
    
    self.inputTextView.contentInset = UIEdgeInsetsMake(numLines >= 6 ? 4.0f : 0.0f, 0.0f, (numLines >= 6 ? 4.0f : 0.0f), 0.0f);
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.inputTextView.scrollEnabled = YES;
    if (numLines >= 6) {
        CGPoint buttomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
        [self.inputTextView setContentOffset:buttomOffset animated:YES];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length-2, 1)];
    }
}
+ (CGFloat)textViewLineHeight {
    return 36.0f; //for fontSize 16.0f
}

+ (CGFloat)maxLines {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 3.0f : 8.0f;
}
+ (CGFloat)maxHeight {
    return ([MessageInputView maxLines] + 1.0f) * [MessageInputView textViewLineHeight];
}

#pragma mark - TextViewdelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceSendButton.selected = NO;
    self.voiceChangeButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    return YES;
}


- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [MessageInputView textViewLineHeight], [MessageInputView textViewLineHeight])];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    return button;
}







@end
