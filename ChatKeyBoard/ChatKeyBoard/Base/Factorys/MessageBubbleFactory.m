//
//  MessageBubbleFactory.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "Header.h"

#import "MessageBubbleFactory.h"

#import "ConfigurationHelper.h"


@implementation MessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(BubbleMessageType)type
                              style:(BubbleImageViewStyle)style
                          meidaType:(BubbleMessageMediaType)mediaType {
    
    NSString *messageTypeString;
    
    switch (style) {
        case BubbleImageViewStyleWeChat:
            messageTypeString = @"weChatBubble";
            break;
        default:
            break;
    }
    switch (type) {
        case BubbleMessageTypeSending:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Sending"];
            break;
        case BubbleMessageTypeReceiving:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Receiving"];
            break;
        default:
            break;
    }
    switch (mediaType) {
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeVideo:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        case BubbleMessageMediaTypeText:
        case BubbleMessageMediaTypeVoice:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            
        default:
            break;
    }
    if (type == BubbleMessageTypeReceiving) {
        NSString *receivingSolidImageName = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableReceivingSolidImageNameKey];
        if (receivingSolidImageName) {
            messageTypeString = receivingSolidImageName;
        }
    } else {
        NSString *sendingSolidImageName = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableSendingSolidImageNameKey];
        if (sendingSolidImageName) {
            messageTypeString = sendingSolidImageName;
        }
    }
    UIImage *bubbleImage = [UIImage imageNamed:messageTypeString];
    UIEdgeInsets bubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle:style];
    UIImage *degeBubbleImage = XL_STRETCH_IMAGE(bubbleImage, bubbleImageEdgeInsets);
    return degeBubbleImage;
}

+ (UIEdgeInsets)bubbleImageEdgeInsetsWithStyle:(BubbleImageViewStyle)style {
    UIEdgeInsets edgeInsets;
    switch (style) {
        case BubbleImageViewStyleWeChat:
            // 类似微信的
            edgeInsets = UIEdgeInsetsMake(30, 28, 85, 28);
            break;
        default:
            break;
    }
    return edgeInsets;
}

@end
