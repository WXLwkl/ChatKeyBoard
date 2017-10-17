//
//  Header.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#ifndef Header_h
#define Header_h


//获取一段时间间隔
#define StartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent()
#define EndTime   NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)


#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

// rgb颜色转换（16进制->10进制）
#define ColorWithHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

// 获取RGB颜色
#define RGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGBColor(r,g,b) RGBAColor(r,g,b,1.0f)
#define RandomColor  RGBColor(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

//ChatKeyBoard背景颜色
#define kChatKeyBoardColor              [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0f]

//键盘显示消失时间
#define kAnimateWithDuration 0.25
//键盘上面的工具条
#define kChatToolBarHeight              49
//表情、更多模块高度
#define kbottomCotainerHeight           224
//表情
#define kFacePanelBottomToolBarWidth    45
#define kFacePanelBottomHeight          35
#define kUIPageControllerHeight         30
//更多
#define kMoreItemH                      80
#define kMoreItemIconSize               60

//整个聊天工具的高度
#define kChatKeyBoardHeight     kChatToolBarHeight + kbottomCotainerHeight

#define isIPhone4_5                (kScreenWidth == 320)
#define isIPhone6_6s               (kScreenWidth == 375)
#define isIPhone6p_6sp             (kScreenWidth == 414)


// iPad
#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIs_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhone_6 (kIs_iPhone && kScreenHeight == 667.0)
#define kIs_iPhone_6P (kIs_iPhone && kScreenHeight == 736.0)


// block self
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

// device verson float value
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// image STRETCH
#define XL_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])



#endif /* Header_h */
