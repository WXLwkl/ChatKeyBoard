//
//  ConfigurationHelper.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>

// (Input Tool Bar Style Key)
extern NSString *kXHMessageInputViewVoiceNormalImageNameKey;
extern NSString *kXHMessageInputViewVoiceHLImageNameKey;
extern NSString *kXHMessageInputViewVoiceHolderImageNameKey;
extern NSString *kXHMessageInputViewVoiceHolderHLImageNameKey;
extern NSString *kXHMessageInputViewExtensionNormalImageNameKey;
extern NSString *kXHMessageInputViewExtensionHLImageNameKey;
extern NSString *kXHMessageInputViewKeyboardNormalImageNameKey;
extern NSString *kXHMessageInputViewKeyboardHLImageNameKey;
extern NSString *kXHMessageInputViewEmotionNormalImageNameKey;
extern NSString *kXHMessageInputViewEmotionHLImageNameKey;
extern NSString *kXHMessageInputViewBackgroundImageNameKey;
extern NSString *kXHMessageInputViewBackgroundColorKey;
extern NSString *kXHMessageInputViewBorderColorKey;
extern NSString *kXHMessageInputViewBorderWidthKey;
extern NSString *kXHMessageInputViewCornerRadiusKey;
extern NSString *kXHMessageInputViewPlaceHolderTextColorKey;
extern NSString *kXHMessageInputViewPlaceHolderKey;
extern NSString *kXHMessageInputViewTextColorKey;


// (Message Table Style Key)
extern NSString *kXHMessageTablePlaceholderImageNameKey;
extern NSString *kXHMessageTableReceivingSolidImageNameKey;
extern NSString *kXHMessageTableSendingSolidImageNameKey;
extern NSString *kXHMessageTableVoiceUnreadImageNameKey;
extern NSString *kXHMessageTableAvatarPalceholderImageNameKey;
extern NSString *kXHMessageTableTimestampBackgroundColorKey;
extern NSString *kXHMessageTableTimestampTextColorKey;
extern NSString *kXHMessageTableAvatarTypeKey; // XHMessageAvatarType for NSNumber， if kXHMessageTableCustomLoadAvatarNetworImageKey is YES, kXHMessageTableAvatarTypeKey is invalid
extern NSString *kXHMessageTableCustomLoadAvatarNetworImageKey; // for NSNumber(BOOL)

@interface ConfigurationHelper : NSObject

@property (nonatomic, strong, readonly) NSArray *popMenuTitles;

@property (nonatomic, strong, readonly) NSDictionary *messageInputViewStyle;

@property (nonatomic, strong, readonly) NSDictionary *messageTableStyle;

+ (instancetype)appearance;

- (void)setupPopMenuTitles:(NSArray *)popMenuTitles;

// The key from (Input Tool Bar Style Key)
- (void)setupMessageInputViewStyle:(NSDictionary *)messageInputViewStyle;

// The key from (Message Table Style Key)
- (void)setupMessageTableStyle:(NSDictionary *)messageTableStyle;
@end
