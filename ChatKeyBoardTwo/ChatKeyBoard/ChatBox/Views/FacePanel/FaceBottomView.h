//
//  FaceBottomView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/31.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceSubjectModel.h"

typedef void(^AddActionBlock)();
typedef void(^SetActionBlock)();

@class FaceBottomView;

@protocol FaceBottomViewDelegate <NSObject>

@optional
/** 点击不同表情，切换 */
- (void)faceBottomView:(FaceBottomView *)faceBottomView didPickerFaceSubjectIndex:(NSInteger)faceSubjectIndex;
- (void)faceBottomViewSendAction:(FaceBottomView *)faceBottomView;

@end


@interface FaceBottomView : UIView

@property (nonatomic, weak) id<FaceBottomViewDelegate> delegate;

@property (nonatomic, copy) AddActionBlock addAction;
@property (nonatomic, copy) SetActionBlock setAction;

- (void)loadFaceSubjectPickerSource:(NSArray<FaceSubjectModel *> *)pickerSource;
- (void)changeFaceSubjectIndex:(NSInteger)subjectIndex;

@end
