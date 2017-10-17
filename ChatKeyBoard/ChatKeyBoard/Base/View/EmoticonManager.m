//
//  EmoticonManager.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/27.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "EmoticonManager.h"
#import "EmoticonDefine.h"

@implementation InputEmoticon
@end

@implementation InputEmoticonCatalog
@end

@implementation InputEmoticonLayout

- (id)initEmojiLayout:(CGFloat)width {
    self = [super init];
    if (self) {
        _rows            = NIMKit_EmojRows;
        _columes         = ((width - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) / NIMKit_EmojImageWidth);
        _itemCountInPage = _rows * _columes -1;
        _cellWidth       = (width - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) / _columes;
        _cellHeight      = NIMKit_EmojCellHeight;
        _imageWidth      = NIMKit_EmojImageWidth;
        _imageHeight     = NIMKit_EmojImageHeight;
        _emoji           = YES;
    }
    return self;
}
- (id)initCharletLayout:(CGFloat)width {
    self = [super init];
    if (self) {
        _rows            = NIMKit_PicRows;
        _columes         = ((width - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) / NIMKit_PicImageWidth);
        _itemCountInPage = _rows * _columes;
        _cellWidth       = (width - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) / _columes;
        _cellHeight      = NIMKit_PicCellHeight;
        _imageWidth      = NIMKit_PicImageWidth;
        _imageHeight     = NIMKit_PicImageHeight;
        _emoji           = NO;
    }
    return self;
}

@end

@interface EmoticonManager ()

@property (nonatomic, strong) NSArray *catalogs;

@end

@implementation EmoticonManager

+ (instancetype)sharedManager {
    static EmoticonManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EmoticonManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self parsePlist];
    }
    return self;
}

- (InputEmoticonCatalog *)emoticonCatalog:(NSString *)catalogID {
    
    for (InputEmoticonCatalog *catalog in self.catalogs) {
        if ([catalog.catalogID isEqualToString:catalogID]) {
            return catalog;
        }
    }
    return nil;
}
- (InputEmoticon *)emoticonByTag:(NSString *)tag {
    InputEmoticon *emoticon = nil;
    if ([tag length]) {
        for (InputEmoticonCatalog *catalog in self.catalogs) {
            emoticon = [catalog.tag2Emoticons objectForKey:tag];
            if (emoticon) {
                break;
            }
        }
    }
    return emoticon;
}
- (InputEmoticon *)emoticonByID:(NSString *)emoticonID {
    InputEmoticon * emoticon = nil;
    if ([emoticonID length]) {
        for (InputEmoticonCatalog *catalog in self.catalogs) {
            emoticon = [catalog.id2Emoticons objectForKey:emoticonID];
            if (emoticon) {
                break;
            }
        }
    }
    return emoticon;
}

- (InputEmoticon *)emoticonByCatalogID:(NSString *)catalogID emoticonID:(NSString *)emoticonID {
    InputEmoticon *emoticon = nil;
    if ([emoticonID length] && [catalogID length]) {
        for (InputEmoticonCatalog *catalog in self.catalogs) {
            if ([catalog.catalogID isEqualToString:catalogID]) {
                emoticon = [catalog.id2Emoticons objectForKey:emoticonID];
                break;
            }
        }
    }
    return emoticon;
}

- (void)parsePlist {
    
    NSMutableArray *catalogs = [NSMutableArray array];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"NIMKitEmoticon" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSString *filePath = [bundle pathForResource:@"emoji" ofType:@"plist" inDirectory:NIMKit_EmojiPath];
    
    if (filePath) {
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        for (NSDictionary *dic in array) {
            NSDictionary *info = dic[@"info"];
            NSArray *emoticons = dic[@"data"];
            InputEmoticonCatalog *catalog = [self catalogByInfo:info emoticons:emoticons];
            [catalogs addObject:catalog];
        }
    }
    _catalogs = catalogs;
}

- (InputEmoticonCatalog *)catalogByInfo:(NSDictionary *)info
                                 emoticons:(NSArray *)emoticonsArray
{
    InputEmoticonCatalog *catalog = [[InputEmoticonCatalog alloc]init];
    catalog.catalogID   = info[@"id"];
    catalog.title       = info[@"title"];
    NSString *iconNamePrefix = NIMKit_EmojiPath;
    NSString *icon      = info[@"normal"];
    catalog.icon = [iconNamePrefix stringByAppendingPathComponent:icon];
    NSString *iconPressed = info[@"pressed"];
    catalog.iconPressed = [iconNamePrefix stringByAppendingPathComponent:iconPressed];
    
    
    NSMutableDictionary *tag2Emoticons = [NSMutableDictionary dictionary];
    NSMutableDictionary *id2Emoticons = [NSMutableDictionary dictionary];
    NSMutableArray *emoticons = [NSMutableArray array];
    
    for (NSDictionary *emoticonDict in emoticonsArray) {
        InputEmoticon *emoticon  = [[InputEmoticon alloc] init];
        emoticon.emoticonID     = emoticonDict[@"id"];
        emoticon.tag            = emoticonDict[@"tag"];
        NSString *fileName      = emoticonDict[@"file"];
        NSString *imageNamePrefix = NIMKit_EmojiPath;
        
        emoticon.fileName = [imageNamePrefix stringByAppendingPathComponent:fileName];
        if (emoticon.emoticonID) {
            [emoticons addObject:emoticon];
            id2Emoticons[emoticon.emoticonID] = emoticon;
        }
        if (emoticon.tag) {
            tag2Emoticons[emoticon.tag] = emoticon;
        }
    }
    
    catalog.emoticons       = emoticons;
    catalog.id2Emoticons    = id2Emoticons;
    catalog.tag2Emoticons   = tag2Emoticons;
    return catalog;
}
@end
