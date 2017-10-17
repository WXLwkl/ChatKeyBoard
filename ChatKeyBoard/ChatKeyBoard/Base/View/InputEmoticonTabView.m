//
//  InputEmoticonTabView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/28.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "InputEmoticonTabView.h"
#import "EmoticonManager.h"


#import "UIImage+XHRounded.h"


#import "Header.h"

const NSInteger InputEmoticonSendButtonWidth = 50;

const CGFloat InputLineBoarder = .5f;

@interface InputEmoticonTabView()

@property (nonatomic,strong) NSMutableArray * tabs;

@property (nonatomic,strong) NSMutableArray * seps;

@end

@implementation InputEmoticonTabView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _tabs = [NSMutableArray array];
        _seps = [NSMutableArray array];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [_sendButton setBackgroundColor:[UIColor blueColor]];
        _sendButton.frame = CGRectMake(self.bounds.size.width - InputEmoticonSendButtonWidth, 0, InputEmoticonSendButtonWidth, kFacePanelBottomHeight);
        [self addSubview:_sendButton];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,InputLineBoarder)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = [UIColor blackColor];
        [self addSubview:view];
    }
    return self;
}


- (void)loadCatalogs:(NSArray *)emoticonCatalogs {
    for (UIView *subView in [_tabs arrayByAddingObjectsFromArray:_seps]) {
        [subView removeFromSuperview];
    }
    [_tabs removeAllObjects];
    [_seps removeAllObjects];
    
    for (InputEmoticonCatalog *catalog in emoticonCatalogs) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage loadImageWithImageName:catalog.icon] forState:UIControlStateNormal];
        [button setImage:[UIImage loadImageWithImageName:catalog.iconPressed] forState:UIControlStateHighlighted];
        [button setImage:[UIImage loadImageWithImageName:catalog.iconPressed] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onTouchTab:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        [self addSubview:button];
        [_tabs addObject:button];
        
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, InputLineBoarder, kFacePanelBottomHeight)];
        sep.backgroundColor = [UIColor blackColor];
        [self addSubview:sep];
        [_seps addObject:sep];
    }
}

- (void)onTouchTab:(UIButton *)sender {
    NSInteger index = [self.tabs indexOfObject:sender];
    [self selectTabIndex:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:didSelectTabIndex:)]) {
        [self.delegate tabView:self didSelectTabIndex:index];
    }
}

- (void)selectTabIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.tabs.count; i++) {
        UIButton *btn = self.tabs[i];
        btn.selected = i == index;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat spacing = 10;
    CGFloat left = spacing;
    for (NSInteger index = 0; index < self.tabs.count; index++) {
        UIButton *button = self.tabs[index];
        button.frame = CGRectMake(left + 40 * index, 0, 40, kFacePanelBottomHeight);
        UIView *sep = self.seps[index];
        sep.frame = CGRectMake(CGRectGetMaxX(button.frame), 0, InputLineBoarder, kFacePanelBottomHeight);
    }
    self.sendButton.frame = CGRectMake(self.bounds.size.width - InputEmoticonSendButtonWidth, 0, InputEmoticonSendButtonWidth, kFacePanelBottomHeight);
}

@end
