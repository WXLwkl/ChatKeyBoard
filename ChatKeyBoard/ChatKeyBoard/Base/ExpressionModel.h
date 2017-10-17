//
//  ExpressionModel.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/25.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EmoticonGroup;

typedef NS_ENUM(NSUInteger, EmoticonType) {
    EmoticonTypeImage = 0, ///< 图片表情
    EmoticonTypeEmoji = 1, ///< Emoji表情
};


@interface Emoticon : NSObject
@property (nonatomic, strong) NSString *chs;  ///< 例如 [吃惊]
@property (nonatomic, strong) NSString *cht;  ///< 例如 [吃驚]
@property (nonatomic, strong) NSString *gif;  ///< 例如 d_chijing.gif
@property (nonatomic, strong) NSString *png;  ///< 例如 d_chijing.png
@property (nonatomic, strong) NSString *code; ///< 例如 0x1f60d
@property (nonatomic, assign) EmoticonType type;
@property (nonatomic, weak) EmoticonGroup *group;
@end


@interface EmoticonGroup : NSObject
@property (nonatomic, strong) NSString *groupID; ///< 例如 com.sina.default
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *nameCN; ///< 例如 浪小花
@property (nonatomic, strong) NSString *nameEN;
@property (nonatomic, strong) NSString *nameTW;
@property (nonatomic, assign) NSInteger displayOnly;
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, strong) NSArray<Emoticon *> *emoticons;

@end

@interface ExtraModel : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *icon_nor;
@property (nonatomic,copy) NSString *icon_sel;
@end

