//
//  FacePanel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FaceSubjectModel;


@interface FacePanel : UIView


//@property (nonatomic, weak) id<FacePanelDelegate> delegate;

- (void)loadFaceSubjectItems:(NSArray<FaceSubjectModel *>*)subjectItems;
@end
