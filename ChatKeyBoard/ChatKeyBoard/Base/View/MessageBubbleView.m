//
//  MessageBubbleView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MessageBubbleView.h"
#import "MessageBubbleHelper.h"
#import "ConfigurationHelper.h"
#import "Header.h"

#define kHaveBubbleMargin 8.0f // 文本、视频、表情气泡上下边的间隙
#define kHaveBubbleVoiceMargin 13.5f // 语音气泡上下边的间隙
#define kHaveBubblePhotoMargin 6.5f // 图片、地理位置气泡上下边的间隙

#define kVoiceMargin 20.0f // 播放语音时的动画控件距离头像的间隙

#define kArrowMarginWidth 5.2f // 箭头宽度

#define kTopAndBottomBubbleMargin 13.0f // 文本在气泡内部的上下间隙
#define kLeftTextHorizontalBubblePadding 13.0f // 文本的水平间隙
#define kRightTextHorizontalBubblePadding 13.0f // 文本的水平间隙

#define kUnReadDotSize 10.0f // 语音未读的红点大小

#define kNoneBubblePhotoMargin (kHaveBubbleMargin - kBubblePhotoMargin) // 在没有气泡的时候，也就是在图片、视频、地理位置的时候，图片内部做了Margin，所以需要减去内部的Margin

@interface MessageBubbleView ()

@property (nonatomic, weak, readwrite) SETextView *displayTextView;

@property (nonatomic, weak, readwrite) UIImageView *bubbleImageView;

@property (nonatomic, weak, readwrite) FLAnimatedImageView *emotionImageView;

@property (nonatomic, weak, readwrite) UIImageView *animationVoiceImageView;

@property (nonatomic, weak, readwrite) UIImageView *voiceUnreadDotImageView;

@property (nonatomic, weak, readwrite) UILabel *voiceDurationLabel;

@property (nonatomic, weak, readwrite) BubblePhotoImageView *bubblePhotoImageView;

@property (nonatomic, weak, readwrite) UIImageView *videoPlayImageView;

@property (nonatomic, weak, readwrite) UILabel *geolocationsLabel;

@property (nonatomic, strong, readwrite) id <MessageModel> message;

@end

@implementation MessageBubbleView

// 获取文本的实际大小
+ (CGFloat)neededWidthForText:(NSString *)text {
    UIFont *systemFont = [[MessageBubbleView appearance] font];
    CGSize textSize = CGSizeMake(CGFLOAT_MAX, 20); // rough accessory size
    CGSize sizeWithFont = [text sizeWithFont:systemFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
#if defined(__LP64__) && __LP64__
    return ceil(sizeWithFont.width);
#else
    return ceilf(sizeWithFont.width);
#endif
}
// 计算文本实际的大小
+ (CGSize)neededSizeForText:(NSString *)text {
    // 实际处理文本的时候
    // 文本只有一行的时候，宽度可能出现很小到最大的情况，所以需要计算一行文字需要的宽度
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : (kIs_iPhone_6 ? 0.6 : (kIs_iPhone_6P ? 0.62 : 0.55)));
    
    CGFloat dyWidth = [MessageBubbleView neededWidthForText:text];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        dyWidth += 5;
    }
    
    CGSize textSize = [SETextView frameRectWithAttributtedString:[[MessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text]
                                                  constraintSize:CGSizeMake(maxWidth, MAXFLOAT)
                                                     lineSpacing:kTextLineSpacing
                                                            font:[[MessageBubbleView appearance] font]].size;
    return CGSizeMake((dyWidth > textSize.width ? textSize.width : dyWidth), textSize.height);
}

// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)photo {
    // 这里需要缩放后的size
    CGSize photoSize = CGSizeMake(140, 140);
    return photoSize;
}

// 计算语音实际大小
+ (CGSize)neededSizeForVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration {
    // 这里的100只是暂时固定，到时候会根据一个函数来计算
    float gapDuration = (!voiceDuration || voiceDuration.length == 0 ? -1 : [voiceDuration floatValue] - 1.0f);
    CGSize voiceSize = CGSizeMake(100 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), 42);
    return voiceSize;
}

// 计算Emotion的高度
+ (CGSize)neededSizeForEmotion {
    return CGSizeMake(100, 100);
}

// 计算LocalPostion的高度
+ (CGSize)neededSizeForLocalPostion {
    return CGSizeMake(140, 140);
}

// 计算Cell需要实际Message内容的大小
+ (CGFloat)calculateCellHeightWithMessage:(id <MessageModel>)message {
    CGSize size = [MessageBubbleView getBubbleFrameWithMessage:message];
    return size.height;
}

// 获取Cell需要的高度
+ (CGSize)getBubbleFrameWithMessage:(id <MessageModel>)message {
    CGSize bubbleSize;
    switch (message.messageMediaType) {
        case BubbleMessageMediaTypeText: {
            CGSize needTextSize = [MessageBubbleView neededSizeForText:message.text];
            bubbleSize = CGSizeMake(needTextSize.width + kLeftTextHorizontalBubblePadding + kRightTextHorizontalBubblePadding + kArrowMarginWidth, needTextSize.height + kHaveBubbleMargin * 2 + kTopAndBottomBubbleMargin * 2); //这里*4的原因是：气泡内部的文本也做了margin，而且margin的大小和气泡的margin一样大小，所以需要加上*2的间隙大小
            break;
        }
        case BubbleMessageMediaTypeVoice: {
            // 这里的宽度是不定的，高度是固定的，根据需要根据语音长短来定制啦
            CGSize needVoiceSize = [MessageBubbleView neededSizeForVoicePath:message.voicePath voiceDuration:message.voiceDuration];
            bubbleSize = CGSizeMake(needVoiceSize.width, needVoiceSize.height + kHaveBubbleVoiceMargin * 2);
            break;
        }
        case BubbleMessageMediaTypeEmotion: {
            // 是否固定大小呢？
            CGSize emotionSize = [MessageBubbleView neededSizeForEmotion];
            bubbleSize = CGSizeMake(emotionSize.width, emotionSize.height + kHaveBubbleMargin * 2);
            break;
        }
        case BubbleMessageMediaTypeVideo: {
            CGSize needVideoConverPhotoSize = [MessageBubbleView neededSizeForPhoto:message.videoConverPhoto];
            bubbleSize = CGSizeMake(needVideoConverPhotoSize.width, needVideoConverPhotoSize.height + kNoneBubblePhotoMargin * 2);
            break;
        }
        case BubbleMessageMediaTypePhoto: {
            CGSize needPhotoSize = [MessageBubbleView neededSizeForPhoto:message.photo];
            bubbleSize = CGSizeMake(needPhotoSize.width, needPhotoSize.height + kHaveBubblePhotoMargin * 2);
            break;
        }
        case BubbleMessageMediaTypeLocalPosition: {
            // 固定大小，必须的
            CGSize localPostionSize = [MessageBubbleView neededSizeForLocalPostion];
            bubbleSize = CGSizeMake(localPostionSize.width, localPostionSize.height + kHaveBubblePhotoMargin * 2);
            break;
        }
        default:
            break;
    }
    return bubbleSize;
}

#pragma mark - UIAppearance Getters

- (UIFont *)font {
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:16.0f];
}

#pragma mark - Getters

// 获取气泡的位置以及大小，比如有文字的气泡，语音的气泡，图片的气泡，地理位置的气泡，Emotion的气泡，视频封面的气泡
- (CGRect)bubbleFrame {
    // 1.先得到MessageBubbleView的实际大小
    CGSize bubbleSize = [MessageBubbleView getBubbleFrameWithMessage:self.message];
    
    // 2.计算起泡的大小和位置
    CGFloat paddingX = 0.0f;
    if (self.message.bubbleMessageType == BubbleMessageTypeSending) {
        paddingX = CGRectGetWidth(self.bounds) - bubbleSize.width;
    }
    
    BubbleMessageMediaType currentMessageMediaType = self.message.messageMediaType;
    
    // 最终减去上下边距的像素就可以得到气泡的位置以及大小
    CGFloat marginY = 0.0;
    CGFloat topSumForBottom = 0.0;
    switch (currentMessageMediaType) {
        case BubbleMessageMediaTypeVoice:
            marginY = kHaveBubbleVoiceMargin;
            topSumForBottom = kHaveBubbleVoiceMargin * 2;
            break;
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeLocalPosition:
            marginY = kHaveBubblePhotoMargin;
            topSumForBottom = kHaveBubblePhotoMargin * 2;
            break;
        default:
            // 文本、视频、表情
            marginY = kHaveBubbleMargin;
            topSumForBottom = kHaveBubbleMargin * 2;
            break;
    }
    
    return CGRectMake(paddingX,
                      marginY,
                      bubbleSize.width,
                      bubbleSize.height - topSumForBottom);
}

#pragma mark - Configure Methods

- (void)configureCellWithMessage:(id <MessageModel>)message {
    _message = message;
    
    [self configureBubbleImageView:message];
    
    [self configureMessageDisplayMediaWithMessage:message];
}

- (void)configureBubbleImageView:(id <MessageModel>)message {
    BubbleMessageMediaType currentType = message.messageMediaType;
    
    _voiceDurationLabel.hidden = YES;
    _voiceUnreadDotImageView.hidden = YES;
    switch (currentType) {
        case BubbleMessageMediaTypeVoice: {
            _voiceDurationLabel.hidden = NO;
            _voiceUnreadDotImageView.hidden = message.isRead;
        }
        case BubbleMessageMediaTypeText:
        case BubbleMessageMediaTypeEmotion: {
            _bubbleImageView.image = [MessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:BubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;
            
            // 只要是文本、语音、第三方表情，都需要把显示尖嘴图片的控件隐藏了
            _bubblePhotoImageView.hidden = YES;
            
            
            if (currentType == BubbleMessageMediaTypeText) {
                // 如果是文本消息，那文本消息的控件需要显示
                _displayTextView.hidden = NO;
                // 那语言的gif动画imageView就需要隐藏了
                _animationVoiceImageView.hidden = YES;
                _emotionImageView.hidden = YES;
            } else {
                // 那如果不文本消息，必须把文本消息的控件隐藏了啊
                _displayTextView.hidden = YES;
                
                // 对语音消息的进行特殊处理，第三方表情可以直接利用背景气泡的ImageView控件
                if (currentType == BubbleMessageMediaTypeVoice) {
                    [_animationVoiceImageView removeFromSuperview];
                    _animationVoiceImageView = nil;
                    
                    UIImageView *animationVoiceImageView = [MessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:message.bubbleMessageType];
                    [self addSubview:animationVoiceImageView];
                    _animationVoiceImageView = animationVoiceImageView;
                    _animationVoiceImageView.hidden = NO;
                } else {
                    _emotionImageView.hidden = NO;
                    
                    _bubbleImageView.hidden = YES;
                    _animationVoiceImageView.hidden = YES;
                }
            }
            break;
        }
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeVideo:
        case BubbleMessageMediaTypeLocalPosition: {
            // 只要是图片和视频消息，必须把尖嘴显示控件显示出来
            _bubblePhotoImageView.hidden = NO;
            
            _videoPlayImageView.hidden = (currentType != BubbleMessageMediaTypeVideo);
            
            _geolocationsLabel.hidden = (currentType != BubbleMessageMediaTypeLocalPosition);
            
            // 那其他的控件都必须隐藏
            _displayTextView.hidden = YES;
            _bubbleImageView.hidden = YES;
            _animationVoiceImageView.hidden = YES;
            _emotionImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (void)configureMessageDisplayMediaWithMessage:(id <MessageModel>)message {
    switch (message.messageMediaType) {
        case BubbleMessageMediaTypeText:
            _displayTextView.attributedText = [[MessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:[message text]];
            break;
        case BubbleMessageMediaTypePhoto:
            [_bubblePhotoImageView configureMessagePhoto:message.photo thumbnailUrl:message.thumbnailUrl originPhotoUrl:message.originPhotoUrl onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case BubbleMessageMediaTypeVideo:
            [_bubblePhotoImageView configureMessagePhoto:message.videoConverPhoto thumbnailUrl:message.thumbnailUrl originPhotoUrl:message.originPhotoUrl onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case BubbleMessageMediaTypeVoice:
            self.voiceDurationLabel.text = [NSString stringWithFormat:@"%@\'\'", message.voiceDuration];
            break;
        case BubbleMessageMediaTypeEmotion:
            // 直接设置GIF
            if (message.emotionPath) {
                NSData *animatedData = [NSData dataWithContentsOfFile:message.emotionPath];
                FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedData];
                _emotionImageView.animatedImage = animatedImage;
            }
            break;
        case BubbleMessageMediaTypeLocalPosition:
            [_bubblePhotoImageView configureMessagePhoto:message.localPositionPhoto thumbnailUrl:nil originPhotoUrl:nil onBubbleMessageType:self.message.bubbleMessageType];
            
            _geolocationsLabel.text = message.geolocations;
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void)configureVoiceDurationLabelFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect voiceFrame = _voiceDurationLabel.frame;
    voiceFrame.origin.x = (self.message.bubbleMessageType == BubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(voiceFrame) : bubbleFrame.origin.x + bubbleFrame.size.width);
    _voiceDurationLabel.frame = voiceFrame;
}

- (void)configureVoiceUnreadDotImageViewFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect voiceUnreadDotFrame = _voiceUnreadDotImageView.frame;
    voiceUnreadDotFrame.origin.x = (self.message.bubbleMessageType == BubbleMessageTypeSending ? bubbleFrame.origin.x + kUnReadDotSize : CGRectGetMaxX(bubbleFrame) - kUnReadDotSize * 2);
    voiceUnreadDotFrame.origin.y = CGRectGetMidY(bubbleFrame) - kUnReadDotSize / 2.0;
    _voiceUnreadDotImageView.frame = voiceUnreadDotFrame;
}

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <MessageModel>)message {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _message = message;
        
        // 1、初始化气泡的背景
        if (!_bubbleImageView) {
            //bubble image
            FLAnimatedImageView *bubbleImageView = [[FLAnimatedImageView alloc] init];
            bubbleImageView.frame = self.bounds;
            bubbleImageView.userInteractionEnabled = YES;
            [self addSubview:bubbleImageView];
            _bubbleImageView = bubbleImageView;
        }
        
        // 2、初始化显示文本消息的TextView
        if (!_displayTextView) {
            SETextView *displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
            displayTextView.textColor = [UIColor colorWithWhite:0.143 alpha:1.000];
            displayTextView.backgroundColor = [UIColor clearColor];
            displayTextView.selectable = NO;
            displayTextView.lineSpacing = kTextLineSpacing;
            displayTextView.font = [[MessageBubbleView appearance] font];
            displayTextView.showsEditingMenuAutomatically = NO;
            displayTextView.highlighted = NO;
            [self addSubview:displayTextView];
            _displayTextView = displayTextView;
        }
        
        // 3、初始化显示图片的控件
        if (!_bubblePhotoImageView) {
            BubblePhotoImageView *bubblePhotoImageView = [[BubblePhotoImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:bubblePhotoImageView];
            _bubblePhotoImageView = bubblePhotoImageView;
            
            if (!_videoPlayImageView) {
                UIImageView *videoPlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageVideoPlay"]];
                [bubblePhotoImageView addSubview:videoPlayImageView];
                _videoPlayImageView = videoPlayImageView;
            }
            
            if (!_geolocationsLabel) {
                UILabel *geolocationsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                geolocationsLabel.numberOfLines = 0;
                geolocationsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                geolocationsLabel.textColor = [UIColor whiteColor];
                geolocationsLabel.backgroundColor = [UIColor clearColor];
                geolocationsLabel.font = [UIFont systemFontOfSize:12];
                [bubblePhotoImageView addSubview:geolocationsLabel];
                _geolocationsLabel = geolocationsLabel;
            }
        }
        
        // 4、初始化显示语音时长的label
        if (!_voiceDurationLabel) {
            UILabel *voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 28, 20)];
            voiceDurationLabel.textColor = [UIColor colorWithWhite:0.579 alpha:1.000];
            voiceDurationLabel.backgroundColor = [UIColor clearColor];
            voiceDurationLabel.font = [UIFont systemFontOfSize:13.f];
            voiceDurationLabel.textAlignment = NSTextAlignmentCenter;
            voiceDurationLabel.hidden = YES;
            [self addSubview:voiceDurationLabel];
            _voiceDurationLabel = voiceDurationLabel;
        }
        
        // 5、初始化显示gif表情的控件
        if (!_emotionImageView) {
            FLAnimatedImageView *emotionImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:emotionImageView];
            _emotionImageView = emotionImageView;
        }
        
        // 6. 初始化显示语音未读标记的imageview
        if (!_voiceUnreadDotImageView) {
            NSString *voiceUnreadImageName = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableVoiceUnreadImageNameKey];
            if (!voiceUnreadImageName) {
                voiceUnreadImageName = @"msg_chat_voice_unread";
            }
            
            UIImageView *voiceUnreadDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kUnReadDotSize, kUnReadDotSize)];
            voiceUnreadDotImageView.image = [UIImage imageNamed:voiceUnreadImageName];
            voiceUnreadDotImageView.hidden = YES;
            [self addSubview:voiceUnreadDotImageView];
            _voiceUnreadDotImageView = voiceUnreadDotImageView;
        }
    }
    return self;
}

- (void)dealloc {
    _message = nil;
    
    _displayTextView = nil;
    
    _bubbleImageView = nil;
    
    _bubblePhotoImageView = nil;
    
    _animationVoiceImageView = nil;
    
    _voiceUnreadDotImageView = nil;
    
    _voiceDurationLabel = nil;
    
    _emotionImageView = nil;
    
    _videoPlayImageView = nil;
    
    _geolocationsLabel = nil;
    
    _font = nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BubbleMessageMediaType currentType = self.message.messageMediaType;
    
    switch (currentType) {
        case BubbleMessageMediaTypeText:
        case BubbleMessageMediaTypeVoice:
        case BubbleMessageMediaTypeEmotion: {
            // 获取实际气泡的大小
            CGRect bubbleFrame = [self bubbleFrame];
            self.bubbleImageView.frame = bubbleFrame;
            
            if (currentType == BubbleMessageMediaTypeText) {
                CGFloat textX = -(kArrowMarginWidth / 2.0);
                if (self.message.bubbleMessageType == BubbleMessageTypeReceiving) {
                    textX = kArrowMarginWidth / 2.0;
                }
                CGRect displayTextViewFrame = CGRectZero;
                displayTextViewFrame.size.width = CGRectGetWidth(bubbleFrame) - kLeftTextHorizontalBubblePadding - kRightTextHorizontalBubblePadding - kArrowMarginWidth;
                displayTextViewFrame.size.height = CGRectGetHeight(bubbleFrame) - kHaveBubbleMargin * 3;
                self.displayTextView.frame = displayTextViewFrame;
                self.displayTextView.center = CGPointMake(self.bubbleImageView.center.x + textX, self.bubbleImageView.center.y);
            }
            
            if (currentType == BubbleMessageMediaTypeVoice) {
                // 配置语音播放的位置
                CGRect animationVoiceImageViewFrame = self.animationVoiceImageView.frame;
                CGFloat voiceImagePaddingX = CGRectGetMaxX(bubbleFrame) - kVoiceMargin - CGRectGetWidth(animationVoiceImageViewFrame);
                if (self.message.bubbleMessageType == BubbleMessageTypeReceiving) {
                    voiceImagePaddingX = CGRectGetMinX(bubbleFrame) + kVoiceMargin;
                }
                animationVoiceImageViewFrame.origin = CGPointMake(voiceImagePaddingX, CGRectGetMidY(bubbleFrame) - CGRectGetHeight(animationVoiceImageViewFrame) / 2.0);  // 垂直居中
                self.animationVoiceImageView.frame = animationVoiceImageViewFrame;
                
                [self configureVoiceDurationLabelFrameWithBubbleFrame:bubbleFrame];
                [self configureVoiceUnreadDotImageViewFrameWithBubbleFrame:bubbleFrame];
            }
            
            if (currentType == BubbleMessageMediaTypeEmotion) {
                CGRect emotionImageViewFrame = bubbleFrame;
                emotionImageViewFrame.size = [MessageBubbleView neededSizeForEmotion];
                self.emotionImageView.frame = emotionImageViewFrame;
            }
            break;
        }
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeVideo:
        case BubbleMessageMediaTypeLocalPosition: {
            CGSize needPhotoSize = [MessageBubbleView neededSizeForPhoto:self.message.photo];
            CGFloat paddingX = 0.0f;
            if (self.message.bubbleMessageType == BubbleMessageTypeSending) {
                paddingX = CGRectGetWidth(self.bounds) - needPhotoSize.width;
            }
            
            CGFloat marginY = kNoneBubblePhotoMargin;
            if (currentType == BubbleMessageMediaTypePhoto || currentType == BubbleMessageMediaTypeLocalPosition) {
                marginY = kHaveBubblePhotoMargin;
            }
            
            CGRect photoImageViewFrame = CGRectMake(paddingX, marginY, needPhotoSize.width, needPhotoSize.height);
            
            self.bubblePhotoImageView.frame = photoImageViewFrame;
            
            self.videoPlayImageView.center = CGPointMake(CGRectGetWidth(photoImageViewFrame) / 2.0, CGRectGetHeight(photoImageViewFrame) / 2.0);
            
            CGRect geolocationsLabelFrame = CGRectMake(11, CGRectGetHeight(photoImageViewFrame) - 47, CGRectGetWidth(photoImageViewFrame) - 20, 40);
            self.geolocationsLabel.frame = geolocationsLabelFrame;
            
            break;
        }
        default:
            break;
    }
}

@end
