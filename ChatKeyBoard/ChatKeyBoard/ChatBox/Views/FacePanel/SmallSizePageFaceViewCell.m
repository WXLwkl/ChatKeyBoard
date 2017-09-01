//
//  SmallSizePageFaceViewCell.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "SmallSizePageFaceViewCell.h"

#import "Header.h"
#import "FaceSubjectModel.h"
#import "FaceButton.h"

#define FaceContainerHeight       kbottomCotainerHeight - kFacePanelBottomHeight - kUIPageControllerHeight 
#define Item                        40.f
#define EdgeDistance                10.f
#define Lines                       3

NSString *const SmallSizeFacePanelfacePickedNotification = @"SmallSizeFacePanelfacePickedNotification";

@interface  SmallSizePageFaceViewCell ()
/** 按钮数组 */
@property (nonatomic, strong) NSMutableArray *buttons;
@end

@implementation SmallSizePageFaceViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger cols = 7;
        if (isIPhone4_5) {cols = 7;}
        else if (isIPhone6_6s) {cols = 8;}
        else if (isIPhone6p_6sp){cols = 9;}
        
        CGFloat vMargin = (FaceContainerHeight - Lines * Item) / (Lines+1);
        CGFloat hMargin = (CGRectGetWidth(self.bounds) - cols * Item - 2*EdgeDistance) / cols;
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < Lines; i++) {
            for (int j = 0; j < cols; j++) {
                FaceButton *btn = [FaceButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(j*Item+EdgeDistance+j*hMargin, i*Item+(i+1)*vMargin, Item, Item);
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
        FaceModel *faceModel = faceData[i];
        FaceButton *btn = self.buttons[i];
        btn.hidden = NO;
        [btn setImage:[UIImage imageNamed:faceModel.faceIcon] forState:UIControlStateNormal];
        btn.faceTitle = faceModel.faceTitle;
    }
    FaceButton *btn = self.buttons[faceData.count];
    btn.hidden = NO;
    [btn setImage:[UIImage imageNamed:@"Delete_ios7"] forState:UIControlStateNormal];
    btn.faceTitle = nil;
    for (NSInteger i = faceData.count + 1; i < self.buttons.count; i++) {
        FaceButton *btn = self.buttons[i];
        btn.hidden = YES;
        btn.faceTitle = nil;
        [btn setImage:nil forState:UIControlStateNormal];
    }
}
- (void)faceBtnClick:(FaceButton *)sender {
    NSLog(@"name %@", sender.faceTitle);
    BOOL isDelete = NO;
    if (sender.faceTitle == nil) {
        isDelete = YES;
    }
    NSDictionary *faceInfo = @{
                               @"FaceName":sender.faceTitle ? sender.faceTitle : @"",
                               @"IsDelete":@(isDelete)
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:SmallSizeFacePanelfacePickedNotification object:faceInfo];
}

@end
