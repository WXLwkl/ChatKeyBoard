//
//  MorePanel.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MorePanel.h"
#import "MoreItemModel.h"
#import "Header.h"

#pragma mark - MoreItemView

@class MoreItemView;

typedef void(^ItemViewAction)(MoreItemView *itemView);

@interface MoreItemView : UIView

@property (nonatomic, copy) ItemViewAction itemViewAction;

@property (nonatomic, strong) MoreItemModel *datas;

@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UILabel *nameLab;

@end

@implementation MoreItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kChatKeyBoardColor;
        
        self.iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.iconBtn.frame = CGRectMake(0, 0, kMoreItemIconSize, kMoreItemIconSize);
        [self.iconBtn addTarget:self action:@selector(iconBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.iconBtn.imageView.contentMode = UIViewContentModeBottom;
        [self addSubview:self.iconBtn];
        
        self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconBtn.frame), kMoreItemIconSize, kMoreItemH- kMoreItemIconSize)];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLab];
    }
    return self;
}

- (void)setDatas:(MoreItemModel *)datas {
    [self.iconBtn setImage:datas.normalIconImage forState:UIControlStateNormal];    
    self.nameLab.text = datas.title;
    self.nameLab.textColor = datas.titleColor ? datas.titleColor : [UIColor blackColor];
    self.nameLab.font = datas.titleFont ? datas.titleFont : [UIFont systemFontOfSize:13.f];
}


- (void)iconBtnClick:(UIButton *)sender {
    if (self.itemViewAction) {
        self.itemViewAction(self);
    }
}

@end


#pragma mark - MorePanel


@interface MorePanel ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *contentView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation MorePanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kChatKeyBoardColor;
        
        [self initSubviews];
        
    }
    return self;
}

- (void)initSubviews {
    
    [self addSubview:self.contentView];
    [self addSubview:self.pageControl];
}
- (void)layoutSubviews {
    
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, kbottomCotainerHeight - kUIPageControllerHeight);
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - kUIPageControllerHeight, self.frame.size.width, kUIPageControllerHeight);
    
    [self loadData];
}

- (void)loadData {
    
    if (!self.shareMenuItems.count)
        return;
    
    NSInteger maxLinesOfPage = 2;
    NSInteger maxColsOfPage = 4;
    
    NSInteger page = (self.shareMenuItems.count / (maxLinesOfPage * maxColsOfPage)) + 1;
    self.pageControl.numberOfPages = page;
    self.contentView.contentSize = CGSizeMake(page * self.frame.size.width, 0);
    
    CGFloat hMargin = (CGRectGetWidth(self.contentView.frame) - kMoreItemIconSize * maxColsOfPage) / (maxColsOfPage + 1);
    CGFloat vMargin = (CGRectGetHeight(self.contentView.frame) - kMoreItemH * maxLinesOfPage) / (maxLinesOfPage + 1);
    
    for (int i = 0; i < self.shareMenuItems.count; i++) {
        NSInteger pageIndex = i / (maxLinesOfPage * maxColsOfPage);
        
        CGFloat x = pageIndex * CGRectGetWidth(self.contentView.frame) + (i % maxColsOfPage) * (kMoreItemIconSize + hMargin) + hMargin;
        
        CGFloat y = ((i - pageIndex * (maxLinesOfPage * maxColsOfPage)) / maxColsOfPage) * (vMargin + kMoreItemH) + vMargin;
        
    
        MoreItemView *itemView = [[MoreItemView alloc] initWithFrame:CGRectMake(x, y, kMoreItemIconSize, kMoreItemH)];
        itemView.datas = self.shareMenuItems[i];
        itemView.tag = i;
        itemView.itemViewAction = ^(MoreItemView *itemView){
            if ([self.delegate respondsToSelector:@selector(didSelecteShareMenuItem:atIndex:)]) {
                [self.delegate didSelecteShareMenuItem:self.shareMenuItems[i] atIndex:i];
            }
        };
        [self.contentView addSubview:itemView];
    }
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger currentIndex = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
        self.pageControl.currentPage = currentIndex;
    }
}
#pragma mark - getter 
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.pagingEnabled = YES;
        _contentView.delegate = self;
    }
    return _contentView;
}
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    }
    return _pageControl;
}

@end
