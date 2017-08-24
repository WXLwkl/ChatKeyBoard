//
//  ChatToolBar.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLTextView.h"
#import "RecordButton.h"


@class ChatToolBar;
@class ChatToolBarItemModel;

@protocol ChatToolBarDelegate <NSObject>

@optional

- (void)chatToolBar:(ChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(ChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(ChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBarSwitchToolBarBtnPressed:(ChatToolBar *)toolBar keyBoardState:(BOOL)change;

- (void)chatToolBarDidStartRecording:(ChatToolBar *)toolBar;
- (void)chatToolBarDidCancelRecording:(ChatToolBar *)toolBar;
- (void)chatToolBarDidFinishRecoding:(ChatToolBar *)toolBar;
- (void)chatToolBarWillCancelRecoding:(ChatToolBar *)toolBar;
- (void)chatToolBarContineRecording:(ChatToolBar *)toolBar;

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatToolBarTextViewDidChange:(UITextView *)textView;
- (void)chatToolBarSendText:(NSString *)text;
@end


@interface ChatToolBar : UIView

@property (nonatomic, weak) id<ChatToolBarDelegate> delegate;

/** 切换barView按钮 */
@property (nonatomic, readonly, strong) UIButton *switchBarBtn;
/** 语音按钮 */
@property (nonatomic, readonly, strong) UIButton *voiceBtn;
/** 表情按钮 */
@property (nonatomic, readonly, strong) UIButton *faceBtn;
/** more按钮 */
@property (nonatomic, readonly, strong) UIButton *moreBtn;
/** 输入文本框 */
@property (nonatomic, readonly, strong) XLTextView *textView;
/** 按住录制语音按钮 */
@property (nonatomic, readonly, strong) RecordButton *recordBtn;


/** 默认为no */
@property (nonatomic, assign) BOOL allowSwitchBar;
/** 以下默认为yes*/
@property (nonatomic, assign) BOOL allowVoice;
@property (nonatomic, assign) BOOL allowFace;
@property (nonatomic, assign) BOOL allowMoreFunc;

@property (readonly) BOOL voiceSelected;
@property (readonly) BOOL faceSelected;
@property (readonly) BOOL moreFuncSelected;
@property (readonly) BOOL switchBarSelected;

/**
 *  配置textView内容
 */
- (void)setTextViewContent:(NSString *)text;
- (void)clearTextViewContent;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;

/**
 *  为开始评论和结束评论做准备
 */
- (void)prepareForBeginComment;
- (void)prepareForEndComment;


/**
 *  加载数据
 */
- (void)loadBarItems:(NSArray<ChatToolBarItemModel *>  *)barItems;

@end
