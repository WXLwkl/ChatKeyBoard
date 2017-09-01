//
//  MiddleSizePageFaceView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MiddleSizePageFaceViewCell.h"

#import "Header.h"
#import "FaceSubjectModel.h"
#import "FaceButton.h"

#define FaceContainerHeight       kbottomCotainerHeight - kFacePanelBottomHeight - kUIPageControllerHeight

#define Item                        60.f
#define Lines                       2
#define Cols                        4

NSString *const MiddleSizeFacePanelfacePickedNotification = @"MiddleSizeFacePanelfacePickedNotification";

@interface MiddleSizePageFaceViewCell ()
/** buttons容器数组 */
@property (nonatomic, strong) NSMutableArray *buttons;
@end
@implementation MiddleSizePageFaceViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat vMargin = (FaceContainerHeight - Lines * Item) / (Lines+1);
        CGFloat hMargin = (kScreenWidth - Cols * Item) / (Cols+1);
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < Lines; ++i) {
            for (int j = 0; j < Cols; ++j) {
                FaceButton *btn = [FaceButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(j*Item+(j+1)*hMargin,i*Item+(i+1)*vMargin,Item,Item);
                [btn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                [array addObject:btn];
            }
        }
        self.buttons = array;
    }
    return self;
}

- (void)loadPerPageFaceData:(NSArray *)faceData {
    for (int i = 0; i < faceData.count; i++) {
        FaceModel *fm = faceData[i];
        FaceButton *btn = self.buttons[i];
        btn.hidden = NO;
        [btn setImage:[UIImage imageNamed:fm.faceIcon] forState:UIControlStateNormal];
        btn.faceTitle = fm.faceTitle;
    }
    
    for (NSInteger i = faceData.count; i < self.buttons.count; ++i) {
        FaceButton *btn = self.buttons[i];
        btn.hidden = YES;
        btn.faceTitle = nil;
        [btn setImage:nil forState:UIControlStateNormal];
    }
}

- (void)faceBtnClick:(FaceButton *)sender {
    NSLog(@"点击的图片 %@", sender.faceTitle);
    [[NSNotificationCenter defaultCenter] postNotificationName:MiddleSizeFacePanelfacePickedNotification object:sender.faceTitle];
}

@end
