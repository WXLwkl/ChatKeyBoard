//
//  EmoticonButton.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/28.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InputEmoticon;

@protocol EmoticonButtonTouchDelegate <NSObject>

- (void)selectedEmoticon:(InputEmoticon *)emoticon catalogID:(NSString *)catalogID;

@end

@interface EmoticonButton : UIButton

@property (nonatomic, strong) InputEmoticon *emoticonData;

@property (nonatomic, copy)   NSString         *catalogID;

@property (nonatomic, weak)   id<EmoticonButtonTouchDelegate> delegate;

+ (EmoticonButton*)iconButtonWithData:(InputEmoticon *)data catalogID:(NSString *)catalogID delegate:( id<EmoticonButtonTouchDelegate>)delegate;

- (void)onIconSelected:(id)sender;

@end
