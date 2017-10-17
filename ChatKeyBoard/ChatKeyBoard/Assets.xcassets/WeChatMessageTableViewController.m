//
//  WeChatMessageTableViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "WeChatMessageTableViewController.h"

#import "AudioPlayerHelper.h"

#import "MessageVideoConverPhotoFactory.h"
#import "DisplayTextViewController.h"
#import "DisplayMediaViewController.h"
#import "DisplayLocationViewController.h"

@interface WeChatMessageTableViewController ()

@property (nonatomic, strong) NSArray *emotionManagers;

@property (nonatomic, strong) MessageTableViewCell *currentSelectedCell;

@end

@implementation WeChatMessageTableViewController

- (Message *)getTextMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    Message *textMessage = [[Message alloc] initWithText:@"这是华捷微信，希望大家喜欢这个开源库，请大家帮帮忙支持这个开源库吧！我是Jack，叫华仔也行，曾宪华就是我啦！" sender:@"华仔" timestamp:[NSDate distantPast]];
    textMessage.avatar = [UIImage imageNamed:@"User"];
    textMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    textMessage.bubbleMessageType = bubbleMessageType;
    
    return textMessage;
}

- (Message *)getPhotoMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    Message *photoMessage = [[Message alloc] initWithPhoto:nil thumbnailUrl:@"http://d.hiphotos.baidu.com/image/pic/item/30adcbef76094b361721961da1cc7cd98c109d8b.jpg" originPhotoUrl:nil sender:@"Jack" timestamp:[NSDate date]];
    photoMessage.avatar = [UIImage imageNamed:@"User"];
    photoMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/JieIcon@2x.png";
    photoMessage.bubbleMessageType = bubbleMessageType;
    
    return photoMessage;
}

- (Message *)getVideoMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"02.mov" ofType:@""];
    Message *videoMessage = [[Message alloc] initWithVideoConverPhoto:[MessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath] videoPath:videoPath videoUrl:nil sender:@"Jayson" timestamp:[NSDate date]];
    videoMessage.avatar = [UIImage imageNamed:@"User"];
    videoMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/JieIcon@2x.png";
    videoMessage.bubbleMessageType = bubbleMessageType;
    
    return videoMessage;
}
- (Message *)getVoiceMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    Message *voiceMessage = [[Message alloc] initWithVoicePath:nil voiceUrl:nil voiceDuration:@"1" sender:@"Jayson" timestamp:[NSDate date] isRead:NO];
    voiceMessage.avatar = [UIImage imageNamed:@"User"];
    voiceMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/JieIcon@2x.png";
    voiceMessage.bubbleMessageType = bubbleMessageType;
    
    return voiceMessage;
}

- (Message *)getEmotionMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    Message *emotionMessage = [[Message alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"emotion1.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
    emotionMessage.avatar = [UIImage imageNamed:@"User"];
    emotionMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/JieIcon@2x.png";
    emotionMessage.bubbleMessageType = bubbleMessageType;
    
    return emotionMessage;
}

- (Message *)getGeolocationsMessageWithBubbleMessageType:(BubbleMessageType)bubbleMessageType {
    Message *localPositionMessage = [[Message alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:113.399444] sender:@"Jack" timestamp:[NSDate date]];
    localPositionMessage.avatar = [UIImage imageNamed:@"User"];
    localPositionMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    localPositionMessage.bubbleMessageType = bubbleMessageType;
    
    return localPositionMessage;
}

- (NSMutableArray *)getTestMessages {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 2; i ++) {
        [messages addObject:[self getPhotoMessageWithBubbleMessageType:(i % 5) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
        
        [messages addObject:[self getVideoMessageWithBubbleMessageType:(i % 6) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
        
        [messages addObject:[self getVoiceMessageWithBubbleMessageType:(i % 4) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
        
        [messages addObject:[self getEmotionMessageWithBubbleMessageType:(i % 2) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
        
        [messages addObject:[self getGeolocationsMessageWithBubbleMessageType:(i % 7) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
        
        [messages addObject:[self getTextMessageWithBubbleMessageType:(i % 2) ? BubbleMessageTypeSending : BubbleMessageTypeReceiving]];
    }
    return messages;
}
- (void)loadDemoDataSource {
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messages = [weakSelf getTestMessages];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.messages = messages;
            [weakSelf.messageTableView reloadData];
            
            [weakSelf scrollToBottomAnimated:NO];
        });
    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (CURRENT_SYS_VERSION >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    }
    self.navigationItem.title = @"聊天";
    // 设置自身用户名
    self.messageSender = @"Jack";
    
    self.allowsPanToDismissKeyboard = YES;
    
    [self loadDemoDataSource];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setBackgroundImage:[UIImage imageNamed:@"TableViewBackgroundImage"]];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)dealloc {
    self.emotionManagers = nil;
}


#pragma mark - MessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<MessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(MessageTableViewCell *)messageTableViewCell {
    
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
            
        case BubbleMessageMediaTypeVideo:
        case BubbleMessageMediaTypePhoto: {
            NSLog(@"message : %@", message.photo);
            NSLog(@"message : %@", message.videoConverPhoto);
            DisplayMediaViewController *messageDisplayTextView = [[DisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case BubbleMessageMediaTypeVoice: {
            NSLog(@"message : %@", message.voicePath);
            
            // Mark the voice as read and hide the red dot.
            message.isRead = YES;
            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            
            [[AudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[AudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[AudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
        case BubbleMessageMediaTypeEmotion:
            NSLog(@"facePath : %@", message.emotionPath);
            break;
        case BubbleMessageMediaTypeLocalPosition: {
            NSLog(@"facePath : %@", message.localPositionPhoto);
            DisplayLocationViewController *displayLocationViewController = [[DisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<MessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    
    
    NSLog(@"text : %@", message.text);
    DisplayTextViewController *displayTextViewController = [[DisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatarOnMessage:(id<MessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath : %@", indexPath);
//    Contact *contact = [[Contact alloc] init];
//    contact.contactName = [message sender];
//    contact.contactIntroduction = @"自定义描述，这个需要和业务逻辑挂钩";
//    ContactDetailTableViewController *contactDetailTableViewController = [[ContactDetailTableViewController alloc] initWithContact:contact];
//    [self.navigationController pushViewController:contactDetailTableViewController animated:YES];
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(BubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}

#pragma mark - AudioPlayerHelper Delegate


- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - MessageTableViewController Delegate
- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

- (void)loadMoreMessagesScrollTotop {
    if (!self.loadingMoreMessage) {
        self.loadingMoreMessage = YES;
        
        WEAKSELF
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *messages = [weakSelf getTestMessages];
            
            //模拟网络延时 3s后加载
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf insertOldMessages:messages];
                weakSelf.loadingMoreMessage = NO;
            });
        });
    }
}

/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *textMessage = [[Message alloc] initWithText:text sender:sender timestamp:date];
    textMessage.avatar = [UIImage imageNamed:@"userHead"];
    textMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypeText];
}

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *photoMessage = [[Message alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
    photoMessage.avatar = [UIImage imageNamed:@"userHead"];
    photoMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:photoMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypePhoto];
}

/**
 *  发送视频消息的回调方法
 *
 *  @param videoPath 目标视频本地路径
 *  @param sender    发送者的名字
 *  @param date      发送时间
 */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *videoMessage = [[Message alloc] initWithVideoConverPhoto:videoConverPhoto videoPath:videoPath videoUrl:nil sender:sender timestamp:date];
    videoMessage.avatar = [UIImage imageNamed:@"userHead"];
    videoMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:videoMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypeVideo];
}

/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *voiceMessage = [[Message alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
    voiceMessage.avatar = [UIImage imageNamed:@"userHead"];
    voiceMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:voiceMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypeVoice];
}

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param emotionPath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    Message *emotionMessage = [[Message alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"emotion1.gif" ofType:nil] sender:sender timestamp:date];
    emotionMessage.avatar = [UIImage imageNamed:@"userHead"];
//    emotionMessage.avatarUrl = @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2259989867,1935385594&fm=27&gp=0.jpg";
    [self addMessage:emotionMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypeEmotion];
}

/**
 *  有些网友说需要发送地理位置，这个我暂时放一放
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *geoLocationsMessage = [[Message alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
    geoLocationsMessage.avatar = [UIImage imageNamed:@"userHead"];
    geoLocationsMessage.avatarUrl = @"http://childapp.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:geoLocationsMessage];
    [self finishSendMessageWithBubbleMessageType:BubbleMessageMediaTypeLocalPosition];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2) {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(MessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    
    return YES;
}



@end
