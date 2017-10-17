//
//  MessageInputView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatToolBar.h"
#import "MoreItemModel.h"

@class MessageInputView;

@protocol MessageInputViewDelegate <NSObject>

@required
/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(UITextView *)messageInputTextView;


/**
 *  更多功能里的回调
 */
- (void)messageInputView:(MessageInputView *)inputView didSelecteShareMenuItem:(MoreItemModel *)moreItem atIndex:(NSInteger)index;

/*!
 * 点击表情键盘的自定义表情，直接发送
 */
- (void)messageInputView:(MessageInputView *)inputView
       didSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId;


/**
 点击表情模块下面的“发送”按钮

 @param inputView inputView
 @param messge 文本的信息
 */
- (void)messageInputView:(MessageInputView *)inputView didPressSend:(NSString *)messge;

@optional
/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(UITextView *)messageInputTextView;
/**
 监听输入框变化
 
 @param messageInputTextView 输入框
 */
- (void)inputTextViewDidChange:(UITextView *)messageInputTextView;
/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)didSendTextAction:(NSString *)text;



/**
 *  在发送文本和语音之间发送改变时，会触发这个回调函数
 *
 *  @param select 是否改为发送语音状态
 */
- (void)didChangeSendVoiceAction:(BOOL)select;
/**
 *  点击表情切换按钮
 */
- (void)didSelectedFaceAction:(BOOL)select;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction:(BOOL)select;




/**
 *  按下录音按钮 "准备" 录音
 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;
/**
 *  开始录音
 */
- (void)didStartRecordingVoiceAction;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction;
/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction;
/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction;




@end

@interface MessageInputView : UIImageView


@property (nonatomic, weak) id<MessageInputViewDelegate> delegate;



///**
// *  当前输入工具条的样式
// */
//@property (nonatomic, assign) MessageInputViewStyle messageInputViewStyle;  // default is XHMessageInputViewStyleFlat
//


/**
 输入框状态
 */
@property (nonatomic, assign) InputViewState inputViewState;


/**
 *  是否允许发送语音
 */
@property (nonatomic, assign) BOOL allowsSendVoice; // default is YES

/**
 *  是否允许发送多媒体
 */
@property (nonatomic, assign) BOOL allowsSendMultiMedia; // default is YES

/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES


@end
