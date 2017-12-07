//
//  LiuqsCellFrame.m
//  chatWithEmotion
//
//  Created by 刘全水 on 16/3/2.
//  Copyright © 2016年 刘全水. All rights reserved.
//

#import "LiuqsCellFrame.h"
#import "LiuqsChangeStrTool.h"
//屏幕尺寸
#define screenH [UIScreen mainScreen].bounds.size.height
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenRate screenW / 320


@implementation LiuqsCellFrame

-(void)setMessage:(LiuqsChatMessage *)message
{
    _message = message;
    
    if ([message.type isEqualToString:@"gif"]) {
        
        self.gifViewFrame = CGRectMake((screenW - 100) / 2, 10, 100, 100);
        
        self.cellHeight = 120;
        
    }else if ([message.type isEqualToString:@"message"]) {
        
//        匹对字符串，获取富文本
        NSMutableAttributedString *text = [LiuqsChangeStrTool changeStrWithStr:message.text Font:[UIFont systemFontOfSize:16] TextColor:[UIColor blackColor]];
        CGSize maxsize = CGSizeMake(screenW - 20, MAXFLOAT);
//        文字自适应
        CGSize TextSize = [text boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
//        CGSize TextSize = [self getSizeWithFont:[UIFont systemFontOfSize:17] andText:message.text];

        self.message.attributedText = (NSMutableAttributedString*)text;
        
        NSString *htmlStr = [LiuqsChangeStrTool changeTextToHtmlStrWithText:message.text];
        
        self.htmlURlStr = htmlStr;
        
        //计算控件frame
        self.emotionLabelFrame = CGRectMake(10, 5, TextSize.width  , TextSize.height);
        
        //计算cell高度
        self.cellHeight = TextSize.height + 10;
    
    }
}

//动态计算size方法
- (CGSize )getSizeWithFont:(UIFont *)font andText:(NSString *)text{
    
    //动态计算label的宽度
    NSDictionary *dict = @{NSFontAttributeName:font};
    
    CGSize maxsize = CGSizeMake(screenW - 20 , MAXFLOAT);
    
    CGSize size = [text boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    return size;
}

@end
