
//  Created by 刘全水 on 15/12/30.
//  Copyright © 2015年 刘全水. All rights reserved.
//

#import "LiuqsChangeStrTool.h"
#import "LiuqsTextAttachment.h"

#import "UIImage+XHRounded.h"

#define checkStr @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"

static CGSize                    _emotionSize;
static UIFont                    *_font;
static UIColor                   *_textColor;
static NSArray                   *_matches;
static NSString                  *_string;
static NSDictionary              *_emojiImages;
static NSMutableArray            *_imageDataArray;
static NSMutableAttributedString *_attStr;
static NSMutableAttributedString *_resultStr;

@implementation LiuqsChangeStrTool

+ (NSMutableAttributedString *)changeStrWithStr:(NSString *)string Font:(UIFont *)font TextColor:(UIColor *)textColor {
    
    _font      = font;
    _string    = string;
    _textColor = textColor;
    [self initProperty];
    [self executeMatch];
    [self setImageDataArray];
    [self setResultStrUseReplace];
    return _resultStr;
}

+ (void)initProperty {
    NSMutableDictionary *catalogD = [NSMutableDictionary dictionary];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"NIMKitEmoticon" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSString *filePath = [bundle pathForResource:@"emoji" ofType:@"plist" inDirectory:@"Emoji"];
    
    
    
    if (filePath) {
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        for (NSDictionary *dic in array) {
            NSArray *emoticons = dic[@"data"];
            for (NSDictionary *d in emoticons) {
                [catalogD setObject:d[@"file"] forKey:d[@"tag"]];
            }
        }
    }
    

    _emojiImages = [NSDictionary dictionaryWithDictionary:catalogD];
    
    //设置文本参数（行间距，文本颜色，字体大小）
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    [paragraphStyle setLineSpacing:4.0f];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_textColor,NSForegroundColorAttributeName,_font,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
    
    CGSize maxsize = CGSizeMake(1000, MAXFLOAT);
    //计算表情的大小
    _emotionSize = [@"/" boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    //保存当前富文本
    _attStr = [[NSMutableAttributedString alloc]initWithString:_string attributes:dict];
    
}


+ (void)executeMatch {
    
    //比对结果（正则验证的过程）
    NSString *regexString = checkStr;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange totalRange = NSMakeRange(0, [_string length]);
    //保存验证结果，结果是一个数组，存放的是NSTextCheckingResult类
    _matches = [regex matchesInString:_string options:0 range:totalRange];
}

+ (void)setImageDataArray {
    
    NSMutableArray *imageDataArray = [NSMutableArray array];
    //遍历_matches
    for (int i = (int)_matches.count - 1; i >= 0; i --) {
        
        NSMutableDictionary *record = [NSMutableDictionary dictionary];
        //创建附件
        LiuqsTextAttachment *attachMent = [[LiuqsTextAttachment alloc]init];
//        设置尺寸
        attachMent.emojiSize = CGSizeMake(_emotionSize.height, _emotionSize.height);
//        取到当前的表情
        NSTextCheckingResult *match = [_matches objectAtIndex:i];
//        取出表情字符串在文本中的位置
        NSRange matchRange = [match range];
        
        NSString *tagString = [_string substringWithRange:matchRange];
//        拿出表情对应的图片名字
        NSString *imageName = [_emojiImages objectForKey:tagString];
//        判断是否有这个图，有就继续没有就跳出当次循环
        if (imageName == nil || imageName.length == 0) continue;
        //这里有个问题，需要先判断是否有图片，没有图片的话应该不操作，因为现在换用html处理，先不改！
        NSString *cheakStr = [imageName substringWithRange:NSMakeRange(1, 2)];
       // 不用管这个判断，操作就是要取出图片，给附件设置图片
        if ([cheakStr intValue] > 60) {
            
            NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"gif"];
            
            NSData *gifData = [NSData dataWithContentsOfFile:path];
            
            attachMent.contents = gifData;
            
            attachMent.fileType = @"gif";
            
        }else {
            NSString *str = [@"Emoji/" stringByAppendingString:imageName];
            UIImage *image = [UIImage loadImageWithImageName:str];
            
            attachMent.image = image;
        }
        
//        然后把表情富文本和对应的位置存到字典中，再把字典存到数组中，这样就得到一个字典数组。
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attachMent];
        
        [record setObject:[NSValue valueWithRange:matchRange] forKey:@"range"];
        
        [record setObject:imageStr forKey:@"image"];
        
        [imageDataArray addObject:record];
    }
    //保存字典数组
    _imageDataArray = imageDataArray;
}

//遍历上一步的字典数组，执行替换并返回一个富文本
+ (void)setResultStrUseReplace{
    
    NSMutableAttributedString *result = _attStr;
    
    for (int i = 0; i < _imageDataArray.count ; i ++) {
        
        NSRange range = [_imageDataArray[i][@"range"] rangeValue];
        
        NSDictionary *imageDic = [_imageDataArray objectAtIndex:i];
        
        NSMutableAttributedString *imageStr = [imageDic objectForKey:@"image"];
        
        [result replaceCharactersInRange:range withAttributedString:imageStr];
    }
    _resultStr = result;
}


#pragma mark - 以下是我用来优化性能方案的代码，暂时不用，只是一个思路现在还有一些问题，不能完美实现！（用网页加载gif，解决大量gif时列表滑动卡顿的问题，目前还无法完美的计算文本内容在网页中所占的尺寸）

+ (NSString *)changeTextToHtmlStrWithText:(NSString *)text {

    _string = text;
    // 读取并加载对照表
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LiuqsEmoji" ofType:@"plist"];
    
    _emojiImages = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [self getHtmlStrimg];
}

+ (NSString *)getHtmlStrimg {

    [self executeMatch];
    
    __block NSMutableString *htmlStr = [NSMutableString stringWithString:_string];
    
    __weak __typeof__(self) weakSelf = self;
    
    for (NSUInteger i = _matches.count; i > 0; i --) {
        
        NSTextCheckingResult *match = [_matches objectAtIndex:i - 1];
        
        NSRange currentRange = [match range];
        
        NSString *tagString = [_string substringWithRange:currentRange];
        
        NSString *imageName = [_emojiImages objectForKey:tagString];
        
        NSString *imageStr = [weakSelf createEmotionShortStrWithImageName:imageName];
        
        [htmlStr replaceCharactersInRange:currentRange withString:imageStr];
    }
    
    return htmlStr;
}

+ (NSString *)createEmotionShortStrWithImageName:(NSString *)imageName {
    
    NSString *cheakStr = [imageName substringWithRange:NSMakeRange(1, 2)];
    
    NSString *type = [NSString string];
    
    if ([cheakStr intValue] > 60) {type = @"gif";}else{type = @"png";}
    
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:type];

    NSURL *imageUrl = [NSURL fileURLWithPath:path];
    
    NSString *result = [NSString stringWithFormat:@"<img src='%@' height='%f' width='%f'>",imageUrl.absoluteString,_emotionSize.height,_emotionSize.height];
    
    return result;
}


@end
