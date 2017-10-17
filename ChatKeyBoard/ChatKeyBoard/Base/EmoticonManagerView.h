//
//  EmoticonManagerView.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonPageView.h"
#import "EmoticonDefine.h"
#import "InputEmoticonTabView.h"

#import "EmoticonManager.h"
#import "Header.h"

@protocol EmoticonManagerViewDelegate <NSObject>

- (void)didPressSend:(id)sender;
- (void)selectedEmoticon:(NSString *)emoticonID catalog:(NSString *)emotCatalogID description:(NSString *)description;

@end


@interface EmoticonManagerView : UIView

@property (nonatomic, strong) EmoticonPageView *emoticonPageView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *totalCatalogData;
@property (nonatomic, strong) InputEmoticonCatalog *currentCatalogData;
@property (nonatomic, strong) NSArray *allEmoticons;
@property (nonatomic, strong) InputEmoticonTabView *tabView;
@property (nonatomic, weak) id<EmoticonManagerViewDelegate> delegate;

@end
