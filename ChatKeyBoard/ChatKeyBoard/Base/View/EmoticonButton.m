//
//  EmoticonButton.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/28.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "EmoticonButton.h"
#import "EmoticonManager.h"

#import "UIImage+XHRounded.h"

@implementation EmoticonButton

+ (EmoticonButton*)iconButtonWithData:(InputEmoticon *)data catalogID:(NSString *)catalogID delegate:( id<EmoticonButtonTouchDelegate>)delegate {
    
    EmoticonButton *icon = [[EmoticonButton alloc] init];
    [icon addTarget:icon action:@selector(onIconSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage loadImageWithImageName:data.fileName];
    
    icon.emoticonData    = data;
    icon.catalogID              = catalogID;
    icon.userInteractionEnabled = YES;
    icon.exclusiveTouch         = YES;
    icon.contentMode            = UIViewContentModeScaleToFill;
    icon.delegate               = delegate;
    [icon setImage:image forState:UIControlStateNormal];
    [icon setImage:image forState:UIControlStateHighlighted];
    return icon;
}



- (void)onIconSelected:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(selectedEmoticon:catalogID:)]) {
        [self.delegate selectedEmoticon:self.emoticonData catalogID:self.catalogID];
    }
}


@end
