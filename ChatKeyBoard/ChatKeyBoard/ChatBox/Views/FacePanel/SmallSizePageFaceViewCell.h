//
//  SmallSizePageFaceViewCell.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 负责小尺寸的表情图片展示 比如：展示emoji类型的
 */
@interface SmallSizePageFaceViewCell : UICollectionViewCell

- (void)loadPerPageFaceData:(NSArray *)faceData;

@end
