//
//  MessageModel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import "MessageBubbleFactory.h"

@class Message;

@protocol  MessageModel <NSObject>

@required
- (NSString *)text;

- (UIImage *)photo;

- (NSString *)thumbnailUrl;

- (NSString *)originPhotoUrl;

- (UIImage *)videoConverPhoto;
- (NSString *)videoPath;
- (NSString *)videoUrl;

- (NSString *)voicePath;
- (NSString *)voiceUrl;
- (NSString *)voiceDuration;

- (UIImage *)localPositionPhoto;
- (NSString *)geolocations;
- (CLLocation *)location;

- (NSString *)emotionPath;

- (UIImage *)avatar;
- (NSString *)avatarUrl;


- (BubbleMessageMediaType)messageMediaType;

- (BubbleMessageType)bubbleMessageType;

@optional

- (BOOL)shouldShowUserName;

- (NSString *)sender;

- (NSDate *)timestamp;

- (BOOL)isRead;
- (void)setIsRead:(BOOL)isRead;


@end
