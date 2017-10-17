//
//  ChatToolBar.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLTextView.h"

typedef NS_ENUM(NSUInteger, InputViewState) {
    InputViewStateNormal = 0,
    InputViewStateVoice,
    InputViewStateText,
    InputViewStateEmotion,
    InputViewStateShareMenu
};



@class ChatToolBar;
@class ChatToolBarItemModel;

@protocol ChatToolBarDelegate <NSObject>

@optional

//录音
- (void)chatToolBarDidStartRecording:(ChatToolBar *)toolBar;
- (void)chatToolBarDidCancelRecording:(ChatToolBar *)toolBar;
- (void)chatToolBarDidFinishRecoding:(ChatToolBar *)toolBar;
- (void)chatToolBarWillCancelRecoding:(ChatToolBar *)toolBar;
- (void)chatToolBarContineRecording:(ChatToolBar *)toolBar;
//输入框
- (void)chatToolBarTextViewWillBeginEditing:(UITextView *)textView;
- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatToolBarTextViewDidChange:(UITextView *)textView;
- (void)chatToolBarSendText:(NSString *)text;

@end


@interface ChatToolBar : UIView

@property (nonatomic, weak) id<ChatToolBarDelegate> delegate;

/** 临时记录输入的textView */
@property (nonatomic, copy) NSString *contentText;


/** 切换barView按钮 */
@property (nonatomic, strong) UIButton *switchBarBtn;
/** 语音按钮 */
@property (nonatomic, strong) UIButton *voiceBtn;
/** 表情按钮 */
@property (nonatomic, strong) UIButton *emoticonBtn;
/** more按钮 */
@property (nonatomic, strong) UIButton *moreBtn;
/** 按住录制语音按钮 */
@property (nonatomic, strong) UIButton *recordBtn;



/** 默认为no */
@property (nonatomic, assign) BOOL allowSwitchBar;
/** 以下默认为yes*/
@property (nonatomic, assign) BOOL allowVoice;
@property (nonatomic, assign) BOOL allowFace;
@property (nonatomic, assign) BOOL allowMoreFunc;


@property (nonatomic, assign) InputViewState state;

@property (nonatomic, assign) BOOL showsKeyboard;

/**
 *  配置textView内容
 */

//输入
- (void)insertText:(NSString *)text;
//删除
- (void)deleteText:(NSRange)range;
//清空
- (void)clearTextViewContent;

- (NSRange)selectedRange;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;


@end
