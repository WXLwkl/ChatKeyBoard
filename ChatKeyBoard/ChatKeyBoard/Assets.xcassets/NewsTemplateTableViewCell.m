//
//  NewsTemplateTableViewCell.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/18.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "NewsTemplateTableViewCell.h"

@implementation NewsTemplateTableViewCell

#pragma mark - Properrtys

- (NewsTemplateContainerView *)newsTemplateContainerView {
    if (!_newsTemplateContainerView) {
        _newsTemplateContainerView = [[NewsTemplateContainerView alloc] initWithFrame:CGRectMake(kNewsTemplateContainerViewSpacing, kNewsTemplateContainerViewSpacing, CGRectGetWidth([[UIScreen mainScreen] bounds]) - kNewsTemplateContainerViewSpacing * 2, kNewsTemplateContainerViewHeight)];
    }
    return _newsTemplateContainerView;
}

#pragma mark - Life Cycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView addSubview:self.newsTemplateContainerView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
