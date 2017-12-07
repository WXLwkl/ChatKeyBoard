//
//  MessageTableViewCell.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageAvatarFactory.h"
#import "ConfigurationHelper.h"
#import "UIView+XHRemoteImage.h"
static const CGFloat kLabelPadding = 5.0f;
static const CGFloat kTimeStampLabelHeight = 20.0f;

static const CGFloat kAvatarPaddingX = 8.0;
static const CGFloat kAvatarPaddingY = 15;

static const CGFloat kUserNameLabelHeight = 20;

@interface MessageTableViewCell () {
    
}

@property (nonatomic, weak, readwrite) MessageBubbleView *messageBubbleView;

@property (nonatomic, weak, readwrite) UIButton *avatarButton;

@property (nonatomic, weak, readwrite) UILabel *userNameLabel;

@property (nonatomic, weak, readwrite) LKBadgeView *timestampLabel;

/**
 *  是否显示时间轴Label
 */
@property (nonatomic, assign) BOOL displayTimestamp;

/**
 *  1、是否显示Time Line的label
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configureTimestamp:(BOOL)displayTimestamp atMessage:(id <MessageModel>)message;

/**
 *  2、配置头像
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configAvatarWithMessage:(id <MessageModel>)message;

/**
 *  3、配置需要显示什么消息内容，比如语音、文字、视频、图片
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configureMessageBubbleViewWithMessage:(id <MessageModel>)message;

/**
 *  头像按钮，点击事件
 *
 *  @param sender 头像按钮对象
 */
- (void)avatarButtonClicked:(UIButton *)sender;

/**
 *  统一一个方法隐藏MenuController，多处需要调用
 */
- (void)setupNormalMenuController;

/**
 *  点击Cell的手势处理方法，用于隐藏MenuController的
 *
 *  @param tapGestureRecognizer 点击手势对象
 */
- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

/**
 *  长按Cell的手势处理方法，用于显示MenuController的
 *
 *  @param longPressGestureRecognizer 长按手势对象
 */
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

/**
 *  单击手势处理方法，用于点击多媒体消息触发方法，比如点击语音需要播放的回调、点击图片需要查看大图的回调
 *
 *  @param tapGestureRecognizer 点击手势对象
 */
- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

/**
 *  双击手势处理方法，用于双击文本消息，进行放大文本的回调
 *
 *  @param tapGestureRecognizer 双击手势对象
 */
- (void)doubleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@implementation MessageTableViewCell

- (void)avatarButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectedAvatarOnMessage:atIndexPath:)]) {
        [self.delegate didSelectedAvatarOnMessage:self.messageBubbleView.message atIndexPath:self.indexPath];
    }
}

#pragma mark - Copying Method

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:) || action == @selector(transpond:) || action == @selector(favorites:) || action == @selector(more:));
}

#pragma mark - Menu Actions

- (void)copyed:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.messageBubbleView.displayTextView.text];
    [self resignFirstResponder];
    NSLog(@"Cell was copy");
}

- (void)transpond:(id)sender {
    NSLog(@"Cell was transpond");
}

- (void)favorites:(id)sender {
    NSLog(@"Cell was favorites");
}

- (void)more:(id)sender {
    NSLog(@"Cell was more");
}

#pragma mark - Setters

- (void)configureCellWithMessage:(id <MessageModel>)message
               displaysTimestamp:(BOOL)displayTimestamp {
    // 1、是否显示Time Line的label
    [self configureTimestamp:displayTimestamp atMessage:message];
    
    // 2、配置头像
    [self configAvatarWithMessage:message];
    
    // 3、配置用户名
    [self configUserNameWithMessage:message];
    
    // 4、配置需要显示什么消息内容，比如语音、文字、视频、图片
    [self configureMessageBubbleViewWithMessage:message];
}

- (void)configureTimestamp:(BOOL)displayTimestamp atMessage:(id <MessageModel>)message {
    self.displayTimestamp = displayTimestamp;
    self.timestampLabel.hidden = !self.displayTimestamp;
    if (displayTimestamp) {
        NSString *dateText = nil;
        NSString *timeText = nil;
        
        NSDate *today = [NSDate date];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:-1];
        NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:today options:0];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:message.timestamp];
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
        NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterday];
        
        if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) {
            dateText = NSLocalizedStringFromTable(@"Today", @"MessageDisplayKitString", @"今天");
        } else if (dateComponents.year == yesterdayComponents.year && dateComponents.month == yesterdayComponents.month && dateComponents.day == yesterdayComponents.day) {
            dateText = NSLocalizedStringFromTable(@"Yesterday", @"MessageDisplayKitString", @"昨天");
        } else {
            dateText = [NSDateFormatter localizedStringFromDate:message.timestamp dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        }
        timeText = [NSDateFormatter localizedStringFromDate:message.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        self.timestampLabel.text = [NSString stringWithFormat:@"%@ %@",dateText,timeText];
    }
}

- (void)configAvatarWithMessage:(id <MessageModel>)message {
    UIImage *avatarPhoto = message.avatar;
    NSString *avatarURL = message.avatarUrl;
    
    if (avatarPhoto) {
        [self configAvatarWithPhoto:avatarPhoto];
        if (avatarURL) {
            [self configAvatarWithPhotoURLString:avatarURL];
        }
    } else if (avatarURL) {
        [self configAvatarWithPhotoURLString:avatarURL];
    } else {
        UIImage *avatarPhoto = [self getAvatarPlaceholderImage];
        [self configAvatarWithPhoto:avatarPhoto];
    }
}

- (UIImage *)getAvatarPlaceholderImage {
    NSString *avatarPalceholderImageName = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableAvatarPalceholderImageNameKey];
    if (!avatarPalceholderImageName) {
        avatarPalceholderImageName = @"avatar";
    }
    return [UIImage imageNamed:avatarPalceholderImageName];
}

- (void)configAvatarWithPhoto:(UIImage *)photo {
    [self.avatarButton setImage:photo forState:UIControlStateNormal];
}

- (void)configAvatarWithPhotoURLString:(NSString *)photoURLString {
    BOOL customLoadAvatarNetworkImage = [[[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableCustomLoadAvatarNetworImageKey] boolValue];
    if (!customLoadAvatarNetworkImage) {
        MessageAvatarType avatarType = [[[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableAvatarTypeKey] integerValue];
        self.avatarButton.messageAvatarType = avatarType;
        [self.avatarButton setImageWithURL:[NSURL URLWithString:photoURLString] placeholer:[self getAvatarPlaceholderImage]];
    }
}

- (void)configUserNameWithMessage:(id <MessageModel>)message {
    self.userNameLabel.text = [message sender];
}

- (void)configureMessageBubbleViewWithMessage:(id <MessageModel>)message {
    
    
    BubbleMessageMediaType currentMediaType = message.messageMediaType;
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubbleImageView.gestureRecognizers) {
        [self.messageBubbleView.bubbleImageView removeGestureRecognizer:gesTureRecognizer];
    }
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubblePhotoImageView.gestureRecognizers) {
        [self.messageBubbleView.bubblePhotoImageView removeGestureRecognizer:gesTureRecognizer];
    }
    switch (currentMediaType) {
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeVideo:
        case BubbleMessageMediaTypeLocalPosition: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.bubblePhotoImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case BubbleMessageMediaTypeText:
        case BubbleMessageMediaTypeVoice:
        case BubbleMessageMediaTypeEmotion: {
            UITapGestureRecognizer *tapGestureRecognizer;
            if (currentMediaType == BubbleMessageMediaTypeText) {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerHandle:)];
            } else {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            }
            tapGestureRecognizer.numberOfTapsRequired = (currentMediaType == BubbleMessageMediaTypeText ? 2 : 1);
            [self.messageBubbleView.bubbleImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        default:
            break;
    }
    [self.messageBubbleView configureCellWithMessage:message];
}

#pragma mark - Gestures

- (void)setupNormalMenuController {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self updateMenuControllerVisiable];
}

- (void)updateMenuControllerVisiable {
    [self setupNormalMenuController];
}

- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
        
    NSArray *popMenuTitles = [[ConfigurationHelper appearance] popMenuTitles];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < popMenuTitles.count; i ++) {
        NSString *title = popMenuTitles[i];
        SEL action = nil;
        switch (i) {
            case 0: {
                if ([self.messageBubbleView.message messageMediaType] == BubbleMessageMediaTypeText) {
                    action = @selector(copyed:);
                }
                break;
            }
            case 1: {
                action = @selector(transpond:);
                break;
            }
            case 2: {
                action = @selector(favorites:);
                break;
            }
            case 3: {
                action = @selector(more:);
                break;
            }
            default:
                break;
        }
        if (action) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
            if (item) {
                [menuItems addObject:item];
            }
        }
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    
    CGRect targetRect = [self convertRect:[self.messageBubbleView bubbleFrame]
                                 fromView:self.messageBubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
     
    [menu setMenuVisible:YES animated:YES];
}

- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setupNormalMenuController];
        if ([self.delegate respondsToSelector:@selector(multiMediaMessageDidSelectedOnMessage:atIndexPath:onMessageTableViewCell:)]) {
            [self.delegate multiMediaMessageDidSelectedOnMessage:self.messageBubbleView.message atIndexPath:self.indexPath onMessageTableViewCell:self];
        }
    }
}

- (void)doubleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didDoubleSelectedOnTextMessage:atIndexPath:)]) {
            [self.delegate didDoubleSelectedOnTextMessage:self.messageBubbleView.message atIndexPath:self.indexPath];
        }
    }
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

#pragma mark - Getters

- (BubbleMessageType)bubbleMessageType {
    return self.messageBubbleView.message.bubbleMessageType;
}

+ (CGFloat)calculateCellHeightWithMessage:(id <MessageModel>)message
                        displaysTimestamp:(BOOL)displayTimestamp {
    
    // 第一，是否有时间戳的显示
    CGFloat timestampHeight = displayTimestamp ? (kTimeStampLabelHeight + kLabelPadding * 2) : 0;
    
    CGFloat userInfoNeedHeight = kAvatarPaddingY + kAvatarImageSize + (message.shouldShowUserName ? kUserNameLabelHeight : 0) + kAvatarPaddingY + timestampHeight;
    
    CGFloat bubbleMessageHeight = [MessageBubbleView calculateCellHeightWithMessage:message] + timestampHeight;
    
    return MAX(bubbleMessageHeight, userInfoNeedHeight);
}

#pragma mark - Life cycle

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self addGestureRecognizer:tapGestureRecognizer];

}

- (instancetype)initWithMessage:(id <MessageModel>)message
              displaysTimestamp:(BOOL)displayTimestamp
                reuseIdentifier:(NSString *)cellIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (self) {
        // 如果初始化成功，那就根据Message类型进行初始化控件，比如配置头像，配置发送和接收的样式
        
        // 1、是否显示Time Line的label
        if (!_timestampLabel) {
            UIColor *timestampLabelTextColor = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableTimestampTextColorKey];
            if (!timestampLabelTextColor) {
                timestampLabelTextColor = [UIColor whiteColor];
            }
            UIColor *timestampBackgroundColor = [[ConfigurationHelper appearance].messageTableStyle objectForKey:kXHMessageTableTimestampBackgroundColorKey];
            if (!timestampBackgroundColor) {
                timestampBackgroundColor = [UIColor colorWithWhite:0.734 alpha:1.000];
            }
            LKBadgeView *timestampLabel = [[LKBadgeView alloc] initWithFrame:CGRectMake(0, kLabelPadding, kScreenWidth, kTimeStampLabelHeight)];
            timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            timestampLabel.badgeColor = timestampBackgroundColor;
            timestampLabel.textColor = timestampLabelTextColor;
            timestampLabel.font = [UIFont systemFontOfSize:10.0f];
            timestampLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, timestampLabel.center.y);
            [self.contentView addSubview:timestampLabel];
            [self.contentView bringSubviewToFront:timestampLabel];
            _timestampLabel = timestampLabel;
        }
        
        // 2、配置头像
        CGRect avatarButtonFrame;
        switch (message.bubbleMessageType) {
            case BubbleMessageTypeReceiving:
                avatarButtonFrame = CGRectMake(kAvatarPaddingX,
                                               kAvatarPaddingY + (self.displayTimestamp ? (kTimeStampLabelHeight + kLabelPadding * 2) : 0),
                                               kAvatarImageSize,
                                               kAvatarImageSize);
                break;
            case BubbleMessageTypeSending:
                avatarButtonFrame = CGRectMake(CGRectGetWidth(self.bounds) - kAvatarImageSize - kAvatarPaddingX,
                                               kAvatarPaddingY + (self.displayTimestamp ? (kTimeStampLabelHeight + kLabelPadding * 2) : 0),
                                               kAvatarImageSize,
                                               kAvatarImageSize);
                break;
            default:
                break;
        }
        
        UIButton *avatarButton = [[UIButton alloc] initWithFrame:avatarButtonFrame];
        [avatarButton setImage:[self getAvatarPlaceholderImage] forState:UIControlStateNormal];
        [avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        
        if (message.shouldShowUserName) {
            // 3、配置用户名
            UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.avatarButton.bounds) + 20, kUserNameLabelHeight)];
            userNameLabel.textAlignment = NSTextAlignmentCenter;
            userNameLabel.backgroundColor = [UIColor clearColor];
            userNameLabel.font = [UIFont systemFontOfSize:12];
            userNameLabel.textColor = [UIColor colorWithRed:0.140 green:0.635 blue:0.969 alpha:1.000];
            [self.contentView addSubview:userNameLabel];
            self.userNameLabel = userNameLabel;
        }
        
        // 4、配置需要显示什么消息内容，比如语音、文字、视频、图片
        if (!_messageBubbleView) {
            // bubble container
            MessageBubbleView *messageBubbleView = [[MessageBubbleView alloc] initWithFrame:CGRectZero message:message];
            [self.contentView addSubview:messageBubbleView];
            [self.contentView sendSubviewToBack:messageBubbleView];
            self.messageBubbleView = messageBubbleView;
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 布局头像
    CGFloat layoutOriginY = kAvatarPaddingY + (self.displayTimestamp ? kTimeStampLabelHeight : 0);
    CGRect avatarButtonFrame = self.avatarButton.frame;
    avatarButtonFrame.origin.y = layoutOriginY;
    avatarButtonFrame.origin.x = ([self bubbleMessageType] == BubbleMessageTypeReceiving) ? kAvatarPaddingX : ((CGRectGetWidth(self.bounds) - kAvatarPaddingX - kAvatarImageSize));
    self.avatarButton.frame = avatarButtonFrame;
    
    if (self.messageBubbleView.message.shouldShowUserName) {
        // 布局用户名
        self.userNameLabel.center = CGPointMake(CGRectGetMidX(avatarButtonFrame), CGRectGetMaxY(avatarButtonFrame) + CGRectGetMidY(self.userNameLabel.bounds));
    }
    
    // 布局消息内容的View
    CGFloat bubbleX = 0.0f;
    CGFloat offsetX = 0.0f;
    if ([self bubbleMessageType] == BubbleMessageTypeReceiving) {
        bubbleX = kAvatarImageSize + kAvatarPaddingX * 2;
    } else {
        offsetX = kAvatarImageSize + kAvatarPaddingX * 2;
    }
    CGFloat timeStampLabelNeedHeight = (self.displayTimestamp ? (kTimeStampLabelHeight + kLabelPadding) : 0);
    
    CGRect bubbleMessageViewFrame = CGRectMake(bubbleX,
                                               timeStampLabelNeedHeight,
                                               CGRectGetWidth(self.contentView.bounds) - bubbleX - offsetX,
                                               CGRectGetHeight(self.contentView.bounds) - timeStampLabelNeedHeight);
    self.messageBubbleView.frame = bubbleMessageViewFrame;
}

- (void)dealloc {
    _avatarButton = nil;
    _timestampLabel = nil;
    _messageBubbleView = nil;
    _indexPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse {
    // 这里做清除工作
    [super prepareForReuse];
    self.messageBubbleView.displayTextView.text = nil;
    self.messageBubbleView.displayTextView.attributedText = nil;
    self.messageBubbleView.bubbleImageView.image = nil;
    self.messageBubbleView.emotionImageView.animatedImage = nil;
    self.messageBubbleView.animationVoiceImageView.image = nil;
    self.messageBubbleView.voiceDurationLabel.text = nil;
    self.messageBubbleView.bubblePhotoImageView.messagePhoto = nil;
    self.messageBubbleView.geolocationsLabel.text = nil;
    
    self.userNameLabel.text = nil;
    [self.avatarButton setImage:nil forState:UIControlStateNormal];
    self.timestampLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
