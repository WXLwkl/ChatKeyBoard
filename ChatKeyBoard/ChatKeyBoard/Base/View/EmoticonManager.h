//
//  EmoticonManager.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/27.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InputEmoticon : NSObject

@property (nonatomic, copy) NSString *emoticonID;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *fileName;

@end

@interface InputEmoticonLayout : NSObject

@property (nonatomic, assign) NSInteger rows;            //行数
@property (nonatomic, assign) NSInteger columes;         //列数
@property (nonatomic, assign) NSInteger itemCountInPage; //每页显示几项
@property (nonatomic, assign) CGFloat   cellWidth;       //单个单元格宽
@property (nonatomic, assign) CGFloat   cellHeight;      //单个单元格搞
@property (nonatomic, assign) CGFloat   imageWidth;      //显示图片的宽
@property (nonatomic, assign) CGFloat   imageHeight;     //显示图片的高
@property (nonatomic, assign) BOOL      emoji;

- (id)initEmojiLayout:(CGFloat)width;
- (id)initCharletLayout:(CGFloat)width;

@end

@interface InputEmoticonCatalog : NSObject

@property (nonatomic, strong) InputEmoticonLayout *layout;
@property (nonatomic,   copy) NSString            *catalogID;
@property (nonatomic,   copy) NSString            *title;
@property (nonatomic, strong) NSDictionary        *id2Emoticons;
@property (nonatomic, strong) NSDictionary        *tag2Emoticons;
@property (nonatomic, strong) NSArray             *emoticons;
@property (nonatomic,   copy) NSString            *icon;          //图标
@property (nonatomic,   copy) NSString            *iconPressed;   //小图标按下的效果
@property (nonatomic, assign) NSInteger           pageCount;      //分页数

@end

@interface EmoticonManager : NSObject

+ (instancetype)sharedManager;

- (InputEmoticonCatalog *)emoticonCatalog:(NSString *)catalogID;
- (InputEmoticon *)emoticonByTag:(NSString *)tag;
- (InputEmoticon *)emoticonByID:(NSString *)emoticonID;
- (InputEmoticon *)emoticonByCatalogID:(NSString *)catalogID emoticonID:(NSString *)emoticonID;

@end
