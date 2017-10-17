//
//  EmoticonPageView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/27.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EmoticonPageView;

@protocol EmoticonPageViewDataSource <NSObject>

- (NSInteger)numberOfPages:(EmoticonPageView *)pageView;
- (UIView *)pageView:(EmoticonPageView *)pageView viewInPage:(NSInteger)index;

@end

@protocol EmoticonPageViewDelegate <NSObject>

@optional
- (void)pageViewScrollEnd:(EmoticonPageView *)pageView currentIndex:(NSInteger)index totolPages:(NSInteger)pages;
- (void)pageViewDidScroll:(EmoticonPageView *)pageView;
- (BOOL)needScrollAnimation;

@end

@interface EmoticonPageView : UIView

@property (nonatomic, weak) id<EmoticonPageViewDelegate> delegate;
@property (nonatomic, weak) id<EmoticonPageViewDataSource> dataSource;

- (void)scrollToPage:(NSInteger)page;
- (void)reloadData;
- (UIView *)viewAtIndex:(NSInteger)index;
- (NSInteger)currentPage;

//旋转相关方法,这两个方法必须配对调用,否则会有问题
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;



@end
