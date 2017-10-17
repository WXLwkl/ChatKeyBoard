//
//  MessageAvatarFactory.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 头像大小以及头像与其他控件的距离
static CGFloat const kAvatarImageSize = 40.0f;
static CGFloat const kAlbumAvatarSpacing = 15.0f;

typedef NS_ENUM(NSInteger, MessageAvatarType) {
    MessageAvatarTypeNormal = 0,
    MessageAvatarTypeSquare,
    MessageAvatarTypeCircle
};


@interface MessageAvatarFactory : NSObject

+ (UIImage *)avatarImageNamed:(UIImage *)originImage
            messageAvatarType:(MessageAvatarType)type;

@end
