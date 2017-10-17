//
//  MessageVoiceFactory.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBubbleFactory.h"

@interface MessageVoiceFactory : NSObject
+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(BubbleMessageType)type;
@end
