//
//  MiddleSizePageFaceViewCell.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 负责展示中间尺寸的表情 ： 比如自定义gif，自己收藏的图片
 */

@interface MiddleSizePageFaceViewCell : UICollectionViewCell

- (void)loadPerPageFaceData:(NSArray *)faceData;

@end
