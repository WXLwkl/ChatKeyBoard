//
//  ChatKeyBoard.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, KeyBoardStyle) {
    KeyBoardStyleChat = 0, //聊天
    KeyBoardStyleComment   //评论
};

@class ChatKeyBoard;
@class ChatToolBar;
@class FacePanel;
@class MorePanel;

#pragma mark - delegate

@protocol ChatKeyBoardDelegate <NSObject>

@optional //可选
/**
 *  语音状态
 */
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard;
- (void)chatKeyBoardWillCancelRecoding:(ChatKeyBoard *)chatKeyBoard;
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard;
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard;
- (void)chatKeyBoardContineRecording:(ChatKeyBoard *)chatKeyBoard;

/**
 *  输入状态
 */
- (void)chatKeyBoardTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatKeyBoardTextViewDidChange:(UITextView *)textView;
- (void)chatKeyBoardSendText:(NSString *)text;

/**
 * 表情
 */
- (void)chatKeyBoardFacePicked:(ChatKeyBoard *)chatKeyBoard faceSize:(NSInteger)faceSize faceName:(NSString *)faceName delete:(BOOL)isDelete;
- (void)chatKeyBoardAddFaceSubject:(ChatKeyBoard *)chatKeyBoard;
- (void)chatKeyBoardSetFaceSubject:(ChatKeyBoard *)chatKeyBoard;

/**
 *  更多功能
 */
- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index;


@end

#pragma mark - DataSource

@protocol ChatKeyBoardDataSource <NSObject>

@required //必须
- (NSArray *)chatKeyBoardMorePanelItems;
- (NSArray *)chatKeyBoardToolbarItems;
- (NSArray *)chatKeyBoardFacePanelSubjectItems;

@end


#pragma mark - view

@interface ChatKeyBoard : UIView


/**
 *  默认是导航栏透明，或者没有导航栏
 */
+ (instancetype)keyBoard;

/**
 *  当导航栏不透明时（强制要导航栏不透明）
 *
 *  @param translucent 是否透明
 *
 *  @return keyboard对象
 */
+ (instancetype)keyBoardWithNavgationBarTranslucent:(BOOL)translucent;


/**
 *  直接传入父视图的bounds过来
 *
 *  @param bounds 父视图的bounds，一般为控制器的view
 *
 *  @return keyboard对象
 */
+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds;


@property (nonatomic, weak) id <ChatKeyBoardDataSource> dataSource;
@property (nonatomic, weak) id <ChatKeyBoardDelegate> delegate;

@property (nonatomic, readonly, strong) ChatToolBar *chatToolBar;
@property (nonatomic, readonly, strong) FacePanel *facePanel;
@property (nonatomic, readonly, strong) MorePanel *morePanel;

/**
 *  设置键盘的风格
 *
 *  默认是 KeyBoardStyleChat
 */
@property (nonatomic, assign) KeyBoardStyle keyBoardStyle;

/**
 *  placeHolder内容
 */
@property (nonatomic, copy) NSString * placeHolder;
/**
 *  placeHolder颜色
 */
@property (nonatomic, strong) UIColor *placeHolderColor;

/**
 *  是否开启语音, 默认开启
 */
@property (nonatomic, assign) BOOL allowVoice;
/**
 *  是否开启表情，默认开启
 */
@property (nonatomic, assign) BOOL allowFace;
/**
 *  是否开启更多功能，默认开启
 */
@property (nonatomic, assign) BOOL allowMore;
/**
 *  是否开启切换工具条的功能，默认关闭
 */
@property (nonatomic, assign) BOOL allowSwitchBar;

/**
 *  如果设置键盘风格为 KeyBoardStyleComment
 *
 *  则以下 两个方法有效
 */

/**
 *  开启评论键盘
 */
- (void)beginComment;

/**
 *  隐藏评论键盘
 */
- (void)endComment;

@end
