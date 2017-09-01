//
//  FaceView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "FaceView.h"

#import "Header.h"
#import "FaceSubjectModel.h"

#import "SmallSizePageFaceViewCell.h"
#import "MiddleSizePageFaceViewCell.h"

NSString *const SmallSizePageFaceViewIdentifier = @"SmallSizePageFaceViewCellIdentifier";
NSString *const MiddleSizePageFaceViewIdentifier = @"MiddleSizePageFaceViewCellIdentifier";

@interface FaceView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

/** 表情主题 */
@property (nonatomic, strong) FaceSubjectModel *subjectModel;
@property (nonatomic, strong) NSArray *pageFaceArray;

@end

@implementation FaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews {
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}

- (void)loadFaceSubject:(FaceSubjectModel *)faceSubject {
    
    self.subjectModel = faceSubject;
    NSInteger numbersOfPerPage = [self numbersOfPerPage:faceSubject];
    
    NSMutableArray * pagesArray = [NSMutableArray array];
    NSInteger counts = faceSubject.faceModels.count;
    
    NSMutableArray *page = nil;
    for (int i = 0; i < counts; i++) {
        if (i % numbersOfPerPage == 0) {
            page = [NSMutableArray array];
            [pagesArray addObject:page];
        }
        [page addObject:faceSubject.faceModels[i]];
    }
    self.pageFaceArray = [NSArray arrayWithArray:pagesArray];
    self.pageControl.numberOfPages = self.pageFaceArray.count;
}
- (NSInteger)numbersOfPerPage:(FaceSubjectModel *)faceSubject {
    
    NSInteger perPageNum = 0;
    if (faceSubject.faceSize == SubjectFaceSizeKindSmall) {
        NSInteger colsNumber = 7;
        if (isIPhone4_5)
            colsNumber = 7;
        else if (isIPhone6_6s)
            colsNumber = 8;
        else if (isIPhone6p_6sp)
            colsNumber = 9;
        perPageNum = colsNumber * 3 - 1;
    } else if (faceSubject.faceSize == SubjectFaceSizeKindMiddle) {
        perPageNum = 4 * 2;
    } else {
        perPageNum = 4 * 2;
    }
    return perPageNum;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pageFaceArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_subjectModel.faceSize == SubjectFaceSizeKindSmall) {
        
        SmallSizePageFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SmallSizePageFaceViewIdentifier forIndexPath:indexPath];
        [cell loadPerPageFaceData:self.pageFaceArray[indexPath.row]];
        return cell;
    } else if (_subjectModel.faceSize == SubjectFaceSizeKindMiddle) {
        
        MiddleSizePageFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiddleSizePageFaceViewIdentifier forIndexPath:indexPath];
        [cell loadPerPageFaceData:self.pageFaceArray[indexPath.row]];
        return cell;
    } else if (_subjectModel.faceSize == SubjectFaceSizeKindBig) {
        return nil;
    } else {
        return nil;
    }
}
#pragma mark -- UIScollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.collectionView) {
        //每页宽度
        CGFloat pageWidth = scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
        [self.pageControl setCurrentPage:currentPage];
    }
}
#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor yellowColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[SmallSizePageFaceViewCell class] forCellWithReuseIdentifier:SmallSizePageFaceViewIdentifier];
        [_collectionView registerClass:[MiddleSizePageFaceViewCell class] forCellWithReuseIdentifier:MiddleSizePageFaceViewIdentifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kUIPageControllerHeight, self.frame.size.width, kUIPageControllerHeight)];
        _pageControl.currentPage = 0;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    }
    return _pageControl;
}
@end
