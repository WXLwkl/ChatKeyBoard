//
//  EmoticonPageView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/27.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "EmoticonPageView.h"

@interface EmoticonPageView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger currentPageForRotation;


- (void)setupControls;

//重新载入的流程
- (void)calculatePageNumbers;
- (void)reloadPage;
- (void)raisePageIndexChangedDelegate;

@end

@implementation EmoticonPageView

#pragma mark - life

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControls];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupControls];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGFloat originalWidth = self.frame.size.width;
    [super setFrame:frame];
    if (originalWidth != frame.size.width) {
        [self reloadData];
    }
}
- (void)dealloc {
    _scrollView.delegate = nil;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_scrollView setFrame:self.bounds];
    CGSize size = self.bounds.size;
    [self.scrollView setContentSize:CGSizeMake(size.width * [self.pages count], size.height)];
    for (NSInteger i = 0; i < self.pages.count; i++) {
        id obj = [self.pages objectAtIndex:i];
        if ([obj isKindOfClass:[UIView class]]) {
            [(UIView *)obj setFrame:CGRectMake(size.width * i, 0, size.width, size.height)];
        }
    }
    BOOL animation = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(needScrollAnimation)]) {
        animation = [self.delegate needScrollAnimation];
    }
    [self.scrollView scrollRectToVisible:CGRectMake(self.currentPage * size.width, 0, size.width, size.height) animated:animation];
}

- (void)setupControls {
    
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_scrollView];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
    }
}
#pragma mark - 对外接口

- (void)scrollToPage:(NSInteger)page {
    if (self.currentPage != page || page == 0) {
        self.currentPage = page;
        [self reloadData];
    }
}

- (void)reloadData {
    [self calculatePageNumbers];
    [self reloadPage];
}

- (UIView *)viewAtIndex:(NSInteger)index {
    UIView *view = nil;
    if (index >= 0 && index < [self.pages count]) {
        id obj = self.pages[index];
        if ([obj isKindOfClass:[UIView class]]) {
            view = obj;
        }
    }
    return view;
}

- (NSInteger)currentPage {
    return _currentPage;
}

- (NSInteger)pageInBound:(NSInteger)value min:(NSInteger)min max:(NSInteger)max {
    if (max < min) {
        max = min;
    }
    NSInteger bounded = value;
    if (bounded > max) {
        bounded = max;
    }
    if (bounded < min) {
        bounded = min;
    }
    return bounded;
}
#pragma mark - Page载入和销毁
- (void)loadPagesForCurrentPage:(NSInteger)currentPage{
    NSUInteger count = [self.pages count];
    if (count == 0) {
        return;
    }
    NSInteger first = [self pageInBound:currentPage - 1 min:0 max:count - 1];
    NSInteger last = [self pageInBound:currentPage + 1  min:0 max:count - 1];
    NSRange range = NSMakeRange(first, last - first + 1);
    for (NSUInteger index = 0; index < count; index++) {
        if (NSLocationInRange(index, range)) {
            id obj = self.pages[index];
            if (![obj isKindOfClass:[UIView class]]) {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageView:viewInPage:)]) {
                    UIView *view = [self.dataSource pageView:self viewInPage:index];
                    [self.pages replaceObjectAtIndex:index withObject:view];
                    [self.scrollView addSubview:view];
                    CGSize size = self.bounds.size;
                    [view setFrame:CGRectMake(size.width * index, 0, size.width, size.height)];
                } else {
                    assert(0);
                }
            }
            
        } else {
            id obj = self.pages[index];
            if ([obj isKindOfClass:[UIView class]]) {
                [obj removeFromSuperview];
                [self.pages replaceObjectAtIndex:index withObject:[NSNull null]];
            }
        }
    }
}
- (void)calculatePageNumbers {
    NSInteger numberOfPages = 0;
    for (id obj in self.pages) {
        if ([obj isKindOfClass:[UIView class]]) {
            [(UIView *)obj removeFromSuperview];
        }
    }
    
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPages:)]) {
        
        
        numberOfPages = [self.dataSource numberOfPages:self];
    }
    self.pages = [NSMutableArray arrayWithCapacity:numberOfPages];
    for (NSInteger i = 0; i < numberOfPages; i++) {
        [self.pages addObject:[NSNull null]];
    }
    //注意，这里设置delegate是因为计算contentsize的时候会引起scrollViewDidScroll执行，修改currentpage的值，这样在贴图（举个例子）前面的分类页数比后面的分类页数多，前面的分类滚动到最后面一页后，再显示后面的分类，会显示不正确
    self.scrollView.delegate = nil;
    CGSize size = self.bounds.size;
    [self.scrollView setContentSize:CGSizeMake(size.width * numberOfPages, size.height)];
    self.scrollView.delegate = self;
    
}
- (void)reloadPage {
    //reload的时候尽量记住上次的位置
    if (self.currentPage >= [self.pages count]) {
        _currentPage = [self.pages count] - 1;
    }
    if (self.currentPage < 0) {
        self.currentPage = 0;
    }
    [self loadPagesForCurrentPage:self.currentPage];
    [self raisePageIndexChangedDelegate];
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger page = (NSInteger)(fabs(offsetX / width));
    if (page >= 0 && page < [self.pages count]) {
        if (self.currentPage == page) {
            return;
        }
        self.currentPage = page;
        [self loadPagesForCurrentPage:self.currentPage];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewDidScroll:)]) {
        [self.delegate pageViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self raisePageIndexChangedDelegate];
}
#pragma mark - 辅助方法
- (void)raisePageIndexChangedDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewScrollEnd:currentIndex:totolPages:)]) {
        [self.delegate pageViewScrollEnd:self currentIndex:self.currentPage totolPages:self.pages.count];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _scrollView.delegate = nil;
    _currentPageForRotation = self.currentPage;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = self.bounds.size;
    self.scrollView.contentSize = CGSizeMake(size.width * self.pages.count, size.height);
    for (NSUInteger i = 0; i < self.pages.count; i++) {
        id obj = self.pages[i];
        if ([obj isKindOfClass:[UIView class]]) {
            [(UIView *)obj setFrame:CGRectMake(size.width * i, 0, size.width, size.height)];
        }
    }
    self.scrollView.contentOffset = CGPointMake(self.currentPageForRotation * self.bounds.size.width, 0);
    self.scrollView.delegate = self;
}
@end
