//
//  MessageAvatarFactory.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MessageAvatarFactory.h"
#import "UIImage+XHRounded.h"

@implementation MessageAvatarFactory
+ (UIImage *)avatarImageNamed:(UIImage *)originImage
            messageAvatarType:(MessageAvatarType)messageAvatarType {
    CGFloat radius = 0.0;
    switch (messageAvatarType) {
        case MessageAvatarTypeNormal:
            return originImage;
            break;
        case MessageAvatarTypeCircle:
            radius = originImage.size.width / 2.0;
            break;
        case MessageAvatarTypeSquare:
            radius = 8;
            break;
        default:
            break;
    }
    UIImage *avatar = [originImage createRoundedWithRadius:radius];
    return avatar;
}

@end
