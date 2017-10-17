//
//  MoreItemModel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/25.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MoreItemModel : NSObject

/**
 *  正常显示图片
 */
@property (nonatomic, strong) UIImage *normalIconImage;

/**
 *  第三方按钮的标题
 */
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIFont *titleFont;

/**
 *  根据正常图片和标题初始化一个Model对象
 *
 *  @param normalIconImage 正常图片
 *  @param title           标题
 *
 *  @return 返回一个Model对象
 */
- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title;

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title
                             titleColor:(UIColor *)titleColor
                              titleFont:(UIFont *)titleFont;


@end
