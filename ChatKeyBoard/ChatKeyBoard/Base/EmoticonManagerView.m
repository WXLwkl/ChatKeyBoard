//
//  EmoticonManagerView.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "EmoticonManagerView.h"
#import "EmoticonDefine.h"
#import "EmoticonButton.h"


#import "UIImage+XHRounded.h"

NSInteger CustomPageControlHeight = 36;
NSInteger CustomPageViewHeight    = 159;

@interface EmoticonManagerView ()<EmoticonPageViewDelegate, EmoticonPageViewDataSource, EmoticonButtonTouchDelegate, InputEmoticonTabViewDelegate>

@property (nonatomic, strong) NSMutableArray *pageData;

@end


@implementation EmoticonManagerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor yellowColor];
        [self initSubviews];
        [self reloadData];
    }
    return self;
}

- (void)initSubviews {
    
    _emoticonPageView                  = [[EmoticonPageView alloc] initWithFrame:self.bounds];
    _emoticonPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _emoticonPageView.dataSource       = self;
    _emoticonPageView.delegate = self;
    [self addSubview:_emoticonPageView];
    
    _pageControl                       = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, CustomPageControlHeight)];
    _pageControl.autoresizingMask      = UIViewAutoresizingFlexibleWidth;
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [self addSubview:_pageControl];
    [_pageControl setUserInteractionEnabled:NO];
    
    
    _tabView = [[InputEmoticonTabView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kFacePanelBottomHeight)];
    _tabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView.delegate = self;
    [_tabView.sendButton addTarget:self action:@selector(didPressSend:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tabView];
    
    if (_currentCatalogData.pageCount > 0) {
        _pageControl.numberOfPages = [_currentCatalogData pageCount];
        _pageControl.currentPage = 0;
    }
}
- (void)setFrame:(CGRect)frame {
    CGFloat originalWidth = self.frame.size.width;
    [super setFrame:frame];
    if (originalWidth != frame.size.width) {
    
        [self reloadData];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.emoticonPageView.frame = CGRectMake(0, 0, self.bounds.size.width, CustomPageViewHeight);
    self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.emoticonPageView.frame), self.bounds.size.width, kUIPageControllerHeight);
    self.tabView.frame = CGRectMake(0, self.bounds.size.height - kFacePanelBottomHeight, self.bounds.size.width, kFacePanelBottomHeight);
    
}

- (void)reloadData {
    NSArray *data = [self loadCatalogAndChartlet];
    self.totalCatalogData   = data;
    self.currentCatalogData = data.firstObject;
}
- (NSArray *)loadCatalogAndChartlet {
    
    NSArray *charlets = [self loadChartlet];
    InputEmoticonCatalog *defaultCatalog = [self loadDefaultCatalog];
    NSArray *catalogs = defaultCatalog ? [@[defaultCatalog] arrayByAddingObjectsFromArray:charlets] : charlets;
    
    
    return catalogs;
}

- (NSArray *)loadChartlet{
    NSArray *chatlets = nil;
    
    chatlets = [self loadChartletEmoticonCatalog];
    
    for (InputEmoticonCatalog *item in chatlets) {
        InputEmoticonLayout *layout = [[InputEmoticonLayout alloc] initCharletLayout:self.bounds.size.width];
        item.layout = layout;
        item.pageCount = [self numberOfPagesWithEmoticon:item];
    }
    
    return chatlets;
}

- (InputEmoticonCatalog *)loadDefaultCatalog {
    
    InputEmoticonCatalog *emoticonCatalog = [[EmoticonManager sharedManager] emoticonCatalog:NIMKit_EmojiCatalog];
    
    if (emoticonCatalog) {
        InputEmoticonLayout *layout = [[InputEmoticonLayout alloc] initEmojiLayout:self.bounds.size.width];
        emoticonCatalog.layout = layout;
        emoticonCatalog.pageCount = [self numberOfPagesWithEmoticon:emoticonCatalog];
    }
    return emoticonCatalog;
}

- (NSInteger)numberOfPagesWithEmoticon:(InputEmoticonCatalog *)emoticonCatalog {
    if(emoticonCatalog.emoticons.count % emoticonCatalog.layout.itemCountInPage == 0) {
        return  emoticonCatalog.emoticons.count / emoticonCatalog.layout.itemCountInPage;
    } else {
        return  emoticonCatalog.emoticons.count / emoticonCatalog.layout.itemCountInPage + 1;
    }
}

- (NSArray *)loadChartletEmoticonCatalog {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"NIMDemoChartlet.bundle"
                                         withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSArray  *paths   = [bundle pathsForResourcesOfType:nil inDirectory:@""];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    for (NSString *path in paths) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            
            InputEmoticonCatalog *catalog = [[InputEmoticonCatalog alloc]init];
            catalog.catalogID = path.lastPathComponent;
            NSArray *resources = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"content"]];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *path in resources) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension;
                InputEmoticon *icon  = [[InputEmoticon alloc] init];
                icon.emoticonID = name;
                icon.fileName   = path;
                [array addObject:icon];
            }
            catalog.emoticons = array;
            
            NSArray *icons     = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"icon"]];
            
            for (NSString *path in icons) {
                NSString *name  = [self stringByDeletingPictureResolution:path.lastPathComponent.stringByDeletingPathExtension];
                if ([name hasSuffix:@"normal"]) {
                    catalog.icon = path;
                }else if([name hasSuffix:@"highlighted"]){
                    catalog.iconPressed = path;
                }
            }
            [res addObject:catalog];
        }
    }
    return res;
}
- (NSString *)stringByDeletingPictureResolution:(NSString *)string {
    NSString *doubleResolution  = @"@2x";
    NSString *tribleResolution = @"@3x";
    NSString *fileName = string.stringByDeletingPathExtension;
    NSString *res = [string copy];
    if ([fileName hasSuffix:doubleResolution] || [fileName hasSuffix:tribleResolution]) {
        res = [fileName substringToIndex:fileName.length - 3];
        if (string.pathExtension.length) {
            res = [res stringByAppendingPathExtension:string.pathExtension];
        }
    }
    return res;
}

//找到某组表情的起始位置
- (NSInteger)pageIndexWithEmoticon:(InputEmoticonCatalog *)emoticonCatalog{
    NSInteger pageIndex = 0;
    for (InputEmoticonCatalog *emoticon in self.totalCatalogData) {
        if (emoticon == emoticonCatalog) {
            break;
        }
        pageIndex += emoticon.pageCount;
    }
    return pageIndex;
}
- (NSInteger)pageIndexWithTotalIndex:(NSInteger)index{
    InputEmoticonCatalog *catelog = [self emoticonWithIndex:index];
    NSInteger begin = [self pageIndexWithEmoticon:catelog];
    return index - begin;
}
- (InputEmoticonCatalog *)emoticonWithIndex:(NSInteger)index {
    NSInteger page  = 0;
    InputEmoticonCatalog *emoticon;
    for (emoticon in self.totalCatalogData) {
        NSInteger newPage = page + emoticon.pageCount;
        if (newPage > index) {
            break;
        }
        page   = newPage;
    }
    return emoticon;
}
#pragma mark - InputEmoticonTabViewDelegate
- (void)tabView:(InputEmoticonTabView *)tabView didSelectTabIndex:(NSInteger) index {
    self.currentCatalogData = self.totalCatalogData[index];
}

#pragma mark - Private
- (void)setCurrentCatalogData:(InputEmoticonCatalog *)currentCatalogData {
    
    
    _currentCatalogData = currentCatalogData;
    [self.emoticonPageView scrollToPage:[self pageIndexWithEmoticon:_currentCatalogData]];
}
- (void)setTotalCatalogData:(NSArray *)totalCatalogData {
    
    _totalCatalogData = totalCatalogData;
    [self.tabView loadCatalogs:totalCatalogData];
}
- (NSArray *)allEmoticons {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (InputEmoticonCatalog *catalog in self.totalCatalogData) {
        [array addObjectsFromArray:catalog.emoticons];
    }
    return array;
}


- (void)didPressSend:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didPressSend:)]) {
        [self.delegate didPressSend:sender];
    }
}

#pragma mark -  config data

- (NSInteger)sumPages {
    __block NSInteger pagesCount = 0;
    [self.totalCatalogData enumerateObjectsUsingBlock:^(InputEmoticonCatalog* data, NSUInteger idx, BOOL *stop) {
        pagesCount += data.pageCount;
    }];
    return pagesCount;
}
- (UIView*)emojPageView:(EmoticonPageView *)pageView inEmoticonCatalog:(InputEmoticonCatalog *)emoticon page:(NSInteger)page {
    UIView *subView = [[UIView alloc] init];
    NSInteger iconHeight    = emoticon.layout.imageHeight;
    NSInteger iconWidth     = emoticon.layout.imageWidth;
    CGFloat startX          = (emoticon.layout.cellWidth - iconWidth) / 2  + NIMKit_EmojiLeftMargin;
    CGFloat startY          = (emoticon.layout.cellHeight- iconHeight) / 2 + NIMKit_EmojiTopMargin;
    int32_t coloumnIndex = 0;
    int32_t rowIndex = 0;
    int32_t indexInPage = 0;
    NSInteger begin = page * emoticon.layout.itemCountInPage;
    NSInteger end   = begin + emoticon.layout.itemCountInPage;
    end = end > emoticon.emoticons.count ? (emoticon.emoticons.count) : end;
    for (NSInteger index = begin; index < end; index ++)
    {
        InputEmoticon *data = [emoticon.emoticons objectAtIndex:index];
        
        EmoticonButton *button = [EmoticonButton iconButtonWithData:data catalogID:emoticon.catalogID delegate:self];
        //计算表情位置
        rowIndex    = indexInPage / emoticon.layout.columes;
        coloumnIndex= indexInPage % emoticon.layout.columes;
        CGFloat x = coloumnIndex * emoticon.layout.cellWidth + startX;
        CGFloat y = rowIndex * emoticon.layout.cellHeight + startY;
        CGRect iconRect = CGRectMake(x, y, iconWidth, iconHeight);
        [button setFrame:iconRect];
        [subView addSubview:button];
        indexInPage ++;
    }
    if (coloumnIndex == emoticon.layout.columes -1)
    {
        rowIndex = rowIndex +1;
        coloumnIndex = -1; //设置成-1是因为显示在第0位，有加1
    }
    if ([emoticon.catalogID isEqualToString:NIMKit_EmojiCatalog]) {
        [self addDeleteEmotButtonToView:subView  ColumnIndex:coloumnIndex RowIndex:rowIndex StartX:startX StartY:startY IconWidth:iconWidth IconHeight:iconHeight inEmoticonCatalog:emoticon];
    }
    return subView;
}

- (void)addDeleteEmotButtonToView:(UIView *)view
                      ColumnIndex:(NSInteger)coloumnIndex
                         RowIndex:(NSInteger)rowIndex
                           StartX:(CGFloat)startX
                           StartY:(CGFloat)startY
                        IconWidth:(CGFloat)iconWidth
                       IconHeight:(CGFloat)iconHeight
                inEmoticonCatalog:(InputEmoticonCatalog *)emoticon {
    
    EmoticonButton *deleteIcon = [[EmoticonButton alloc] init];
    deleteIcon.delegate = self;
    deleteIcon.userInteractionEnabled = YES;
    deleteIcon.exclusiveTouch = YES;
    deleteIcon.contentMode = UIViewContentModeCenter;
    NSString *prefix = NIMKit_EmojiPath;
    NSString *imageNormalName = [prefix stringByAppendingPathComponent:@"emoji_del_normal"];
    NSString *imagePressName = [prefix stringByAppendingPathComponent:@"emoji_del_pressed"];
    UIImage *imageNormal  = [UIImage loadImageWithImageName:imageNormalName];
    UIImage *imagePressed = [UIImage loadImageWithImageName:imagePressName];
    
    [deleteIcon setImage:imageNormal forState:UIControlStateNormal];
    [deleteIcon setImage:imagePressed forState:UIControlStateHighlighted];
    [deleteIcon addTarget:deleteIcon action:@selector(onIconSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat newX = (coloumnIndex +1) * emoticon.layout.cellWidth + startX;
    CGFloat newY = rowIndex * emoticon.layout.cellHeight + startY;
    CGRect deleteIconRect = CGRectMake(newX, newY, NIMKit_DeleteIconWidth, NIMKit_DeleteIconHeight);
    
    [deleteIcon setFrame:deleteIconRect];
    [view addSubview:deleteIcon];
}


#pragma mark - EmoticonPageViewDataSource && EmoticonPageViewDelegate
- (NSInteger)numberOfPages:(EmoticonPageView *)pageView {
    return [self sumPages];
}
- (UIView *)pageView:(EmoticonPageView *)pageView viewInPage: (NSInteger)index {
    NSInteger page  = 0;
    InputEmoticonCatalog *emoticon;
    for (emoticon in self.totalCatalogData) {
        NSInteger newPage = page + emoticon.pageCount;
        if (newPage > index) {
            break;
        }
        page   = newPage;
    }
    return [self emojPageView:pageView inEmoticonCatalog:emoticon page:index - page];
}

- (void)pageViewScrollEnd:(EmoticonPageView *)pageView
             currentIndex:(NSInteger)index
               totolPages:(NSInteger)pages {
    
    InputEmoticonCatalog *emticon = [self emoticonWithIndex:index];
    self.pageControl.numberOfPages = [emticon pageCount];
    self.pageControl.currentPage = [self pageIndexWithTotalIndex:index];
    
    NSInteger selectTabIndex = [self.totalCatalogData indexOfObject:emticon];
    [self.tabView selectTabIndex:selectTabIndex];
}

#pragma mark - EmoticonButtonTouchDelegate
- (void)selectedEmoticon:(InputEmoticon *)emoticon catalogID:(NSString *)catalogID {
    
    if ([self.delegate respondsToSelector:@selector(selectedEmoticon:catalog:description:)]) {
        [self.delegate selectedEmoticon:emoticon.emoticonID catalog:catalogID description:emoticon.tag];
    }
}

@end
