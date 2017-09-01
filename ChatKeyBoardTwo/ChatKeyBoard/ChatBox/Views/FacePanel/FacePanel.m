//
//  FacePanel.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "FacePanel.h"
#import "Header.h"

#import "FaceBottomView.h"
#import "FaceView.h"

extern NSString * SmallSizeFacePanelfacePickedNotification;
extern NSString * MiddleSizeFacePanelfacePickedNotification;

@interface FacePanel ()<FaceBottomViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) FaceBottomView *bottomView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *faceSources;

@end

@implementation FacePanel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SmallSizeFacePanelfacePickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MiddleSizeFacePanelfacePickedNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kChatKeyBoardColor;
        
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews {
    
    [self addSubview:self.bottomView];
    [self addSubview:self.scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smallFaceClick:) name:SmallSizeFacePanelfacePickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(middleFaceClick:) name:MiddleSizeFacePanelfacePickedNotification object:nil];
}
#pragma mark -- NSNotificationCenter
- (void)smallFaceClick:(NSNotification *)noti {
    
    NSDictionary *info = [noti object];
    NSString *faceName = [info objectForKey:@"FaceName"];
    BOOL isDelete = [[info objectForKey:@"IsDelete"] boolValue];
    
    if ([self.delegate respondsToSelector:@selector(facePanelFacePicked:faceSize:faceName:delete:)]) {
        [self.delegate facePanelFacePicked:self faceSize:0 faceName:faceName delete:isDelete];
    }
}
- (void)middleFaceClick:(NSNotification *)noti {
    NSString *faceName = [noti object];
    if ([self.delegate respondsToSelector:@selector(facePanelFacePicked:faceSize:faceName:delete:)]) {
        [self.delegate facePanelFacePicked:self faceSize:1 faceName:faceName delete:NO];
    }
}
#pragma mark - 加载数据
- (void)loadFaceSubjectItems:(NSArray<FaceSubjectModel *> *)subjectItems {
    
    self.faceSources = subjectItems;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * self.faceSources.count, 0);
    
    for (int i = 0; i < subjectItems.count; i++) {
        FaceView *faceView = [[FaceView alloc] initWithFrame:(CGRect){CGPointMake(i * self.scrollView.bounds.size.width, 0),self.scrollView.bounds.size}];
        faceView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.f green:arc4random_uniform(255)/255.f  blue:arc4random_uniform(255)/255.f  alpha:1.f];
        [faceView loadFaceSubject:self.faceSources[i]];
        [self.scrollView addSubview:faceView];
    }
    [self.bottomView loadFaceSubjectPickerSource:self.faceSources];
}

#pragma mark - FaceBottomViewDelegate
- (void)faceBottomViewSendAction:(FaceBottomView *)faceBottomView {
    
    if ([self.delegate respondsToSelector:@selector(facePanelSendTextAction:)]) {
        [self.delegate facePanelSendTextAction:self];
    }
}
- (void)faceBottomView:(FaceBottomView *)faceBottomView didPickerFaceSubjectIndex:(NSInteger)faceSubjectIndex {
    
    [_scrollView setContentOffset:CGPointMake(faceSubjectIndex*self.frame.size.width, 0) animated:YES];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        
        CGFloat pageWith = scrollView.frame.size.width;
        NSInteger currentIndex = floor((scrollView.contentOffset.x - pageWith/2)/pageWith) + 1;
        [self.bottomView changeFaceSubjectIndex:currentIndex];
    }
}

#pragma mark - lazy
- (FaceBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[FaceBottomView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kFacePanelBottomHeight, self.frame.size.width, kFacePanelBottomHeight)];
        _bottomView.delegate = self;
        
        __weak __typeof(self) weakSelf = self;
        _bottomView.addAction = ^(){
            if ([weakSelf.delegate respondsToSelector:@selector(facePanelAddSubject:)]) {
                [weakSelf.delegate facePanelAddSubject:weakSelf];
            }
        };
        
        _bottomView.setAction = ^(){
            if ([weakSelf.delegate respondsToSelector:@selector(facePanelSetSubject:)]) {
                [weakSelf.delegate facePanelSetSubject:weakSelf];
            }
        };
    }
    return _bottomView;
}
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kbottomCotainerHeight-kFacePanelBottomHeight)];
        _scrollView.backgroundColor = [UIColor orangeColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

@end
