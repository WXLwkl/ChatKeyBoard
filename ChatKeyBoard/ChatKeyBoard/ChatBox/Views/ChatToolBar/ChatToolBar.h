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


/** 输入文本框 */
@property (nonatomic, strong) XLTextView *textView;

/** 默认为no */
@property (nonatomic, assign) BOOL allowSwitchBar;
/** 以下默认为yes*/
@property (nonatomic, assign) BOOL allowVoice;
@property (nonatomic, assign) BOOL allowFace;
@property (nonatomic, assign) BOOL allowMoreFunc;

@property (nonatomic, assign) BOOL voiceSelected;
@property (nonatomic, assign) BOOL faceSelected;
@property (nonatomic, assign) BOOL moreFuncSelected;
@property (nonatomic, assign) BOOL switchBarSelected;

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


@end
