//
//  MessageBubbleView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "Header.h"

#import <UIKit/UIKit.h>

#import "Message.h"

#import "MessageTextView.h"
#import "MessageInputView.h"

#import "SETextView.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

#import "BubblePhotoImageView.h"

#import "MessageVoiceFactory.h"

#define kMessageBubbleDisplayMaxLine 200
#define kTextLineSpacing 3.0

@interface MessageBubbleView : UIView

/**
 *  目标消息Model对象
 */
@property (nonatomic, strong, readonly)  id <MessageModel> message;
/**
 *  自定义显示文本消息控件，子类化的原因有两个，第一个是屏蔽Menu的显示。第二是传递手势到下一层，因为文本需要双击的手势
 */
@property (nonatomic, weak, readonly) UILabel *displayTextView;

/**
 *  用于显示气泡的ImageView控件
 */
@property (nonatomic, weak, readonly) UIImageView *bubbleImageView;

/**
 *  专门用于gif表情显示控件
 */
@property (nonatomic, weak, readonly) FLAnimatedImageView *emotionImageView;

/**
 *  用于显示语音的控件，并且支持播放动画
 */
@property (nonatomic, weak, readonly) UIImageView *animationVoiceImageView;
/**
 *  用于显示语音未读的控件，小圆点
 */
@property (nonatomic, weak, readonly) UIImageView *voiceUnreadDotImageView;

/**
 *  用于显示语音时长的label
 */
@property (nonatomic, weak, readonly) UILabel *voiceDurationLabel;

/**
 *  用于显示仿微信发送图片的控件
 */
@property (nonatomic, weak, readonly) BubblePhotoImageView *bubblePhotoImageView;

/**
 *  显示语音播放的图片控件
 */
@property (nonatomic, weak, readonly) UIImageView *videoPlayImageView;

/**
 *  显示地理位置的文本控件
 */
@property (nonatomic, weak, readonly) UILabel *geolocationsLabel;

/**
 *  设置文本消息的字体
 */
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;

/**
 *  初始化消息内容显示控件的方法
 *
 *  @param frame   目标Frame
 *  @param message 目标消息Model对象
 *
 *  @return 返回MessageBubbleView类型的对象
 */
- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <MessageModel>)message;

/**
 *  获取气泡相对于父试图的位置
 *
 *  @return 返回气泡的位置
 */
- (CGRect)bubbleFrame;

/**
 *  根据消息Model对象配置消息显示内容
 *
 *  @param message 目标消息Model对象
 */
- (void)configureCellWithMessage:(id <MessageModel>)message;

/**
 *  根据消息Model对象计算消息内容的高度
 *
 *  @param message 目标消息Model对象
 *
 *  @return 返回所需高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(id <MessageModel>)message;


@end
