//
//  FacePanel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceSubjectModel;
@class FacePanel;

@protocol FacePanelDelegate <NSObject>
/** 点击表情图标后 */
- (void)facePanelFacePicked:(FacePanel *)facePanel faceSize:(NSInteger)faceSize faceName:(NSString *)faceName delete:(BOOL)isDelete;
- (void)facePanelSendTextAction:(FacePanel *)facePanel;
- (void)facePanelAddSubject:(FacePanel *)facePanel;
- (void)facePanelSetSubject:(FacePanel *)facePanel;

@end


@interface FacePanel : UIView

@property (nonatomic, weak) id<FacePanelDelegate> delegate;

/** 加载数据 */
- (void)loadFaceSubjectItems:(NSArray<FaceSubjectModel *>*)subjectItems;

@end
