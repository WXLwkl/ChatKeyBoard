//
//  XLMessageTableViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/14.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "XLMessageTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VoiceRecordHUD.h"

#import "MessageVideoConverPhotoFactory.h"

#import "PhotographyHelper.h"
#import "LocationHelper.h"
#import "VoiceRecordHelper.h"


#import "Header.h"


@interface XLMessageTableViewController ()<
    UITableViewDelegate,
    UITableViewDataSource,
    MessageTableViewControllerDelegate,
    MessageTableViewControllerDataSource,
    MessageInputViewDelegate,
    MessageTableViewCellDelegate
>

/**
 *  判断是否用户手指滚动
 */
@property (nonatomic, assign) BOOL isUserScrolling;



@property (nonatomic, strong, readwrite) UITableView *messageTableView;
@property (nonatomic, strong, readwrite) MessageInputView *messageInputView;
@property (nonatomic, strong, readwrite) VoiceRecordHUD *voiceRecordHUD;


@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityIndicatorView;

/**
 *  管理本机的摄像和图片库的工具对象
 */
@property (nonatomic, strong) PhotographyHelper *photographyHelper;

/**
 *  管理地理位置的工具对象
 */
@property (nonatomic, strong) LocationHelper *locationHelper;

/**
 *  管理录音工具对象
 */
@property (nonatomic, strong) VoiceRecordHelper *voiceRecordHelper;

/**
 *  判断是不是超出了录音最大时长
 */
@property (nonatomic) BOOL isMaxTimeStop;



@end

@implementation XLMessageTableViewController

#pragma mark - DataSource Change
/**
 *  改变数据源需要的子线程
 *
 *  @param queue 子线程执行完成的回调block
 */
- (void)exChangeMessageDataSourceQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}
/**
 *  执行块代码在主线程
 *
 *  @param queue 主线程执行完成回调block
 */
- (void)exMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

#pragma mark - 消息
/**
 添加一条新的消息
 */
- (void)addMessage:(Message *)addedMessage {
    WEAKSELF
    [self exChangeMessageDataSourceQueue:^{
        NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
        [messages addObject:addedMessage];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
        [indexPaths addObject:[NSIndexPath indexPathForRow:messages.count - 1 inSection:0]];
        
        [weakSelf exMainQueue:^{
            
            
            weakSelf.messages = messages;
            [weakSelf.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf scrollToBottomAnimated:YES];
        }];
    }];
}

/**
 删除一条已存在的消息
 */
- (void)removeMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.messages.count)
        return;
    [self.messages removeObjectAtIndex:indexPath.row];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:indexPath];
    
    [self.messageTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

static CGPoint  delayOffset = {0.0};

/**
 插入旧消息数据到头部，仿微信的做法
 */
- (void)insertOldMessages:(NSArray *)oldMessages {
    [self insertOldMessages:oldMessages completion:nil];
}

- (void)insertOldMessages:(NSArray *)oldMessages completion:(void (^)())completion {
    WEAKSELF
    [self exChangeMessageDataSourceQueue:^{
        delayOffset = weakSelf.messageTableView.contentOffset;
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:oldMessages.count];
        NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
        [oldMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
            
            delayOffset.y += [weakSelf calculateCellHeightWithMessage:[oldMessages objectAtIndex:idx] atIndexPath:indexPath];
            [indexSets addIndex:idx];
        }];
        
        NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:weakSelf.messages];
        [messages insertObjects:oldMessages atIndexes:indexSets];
        
        
        [weakSelf exMainQueue:^{
            [UIView setAnimationsEnabled:NO];
            weakSelf.messageTableView.userInteractionEnabled = NO;
            //[self.messageTableView beginUpdates];
            
            weakSelf.messages = messages;
            
            [weakSelf.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            
            //[self.messageTableView endUpdates];
            
            [UIView setAnimationsEnabled:YES];
            
            [weakSelf.messageTableView setContentOffset:delayOffset animated:NO];
            weakSelf.messageTableView.userInteractionEnabled = YES;
            if (completion) {
                completion();
            }
        }];
    }];
}


#pragma mark - Messages View Controller

- (void)finishSendMessageWithBubbleMessageType:(BubbleMessageMediaType)mediaType {
    switch (mediaType) {
        case BubbleMessageMediaTypeText: {
//            [self.messageInputView.inputTextView setText:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//                self.messageInputView.inputTextView.enablesReturnKeyAutomatically = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    self.messageInputView.inputTextView.enablesReturnKeyAutomatically = YES;
//                    [self.messageInputView.inputTextView reloadInputViews];
                });
            }
            break;
        }
        case BubbleMessageMediaTypePhoto:
        case BubbleMessageMediaTypeVideo:
        case BubbleMessageMediaTypeVoice:
        case BubbleMessageMediaTypeEmotion:
        case BubbleMessageMediaTypeLocalPosition:
            break;
        
        default:
            break;
    }
}

- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.messageTableView.backgroundColor = color;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    
    self.messageTableView.backgroundView = nil;
    self.messageTableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)position
                      animated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    [self.messageTableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:position
                                         animated:animated];
}

#pragma mark - Other Menu View Frame Helper Mehtod
/**
 根据显示或隐藏的需求对所有第三方Menu进行管理
 */
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        __block CGRect inputViewFrame = self.messageInputView.frame;
        //        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame) + kbottomCotainerHeight) : (CGRectGetMaxY(self.view.frame) - 64 - CGRectGetHeight(inputViewFrame)));
            self.messageInputView.frame = inputViewFrame;
        };
        
        //        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
        //            otherMenuViewFrame = self.emotionManagerView.frame;
        //            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
        //            self.emotionManagerView.alpha = !hide;
        //            self.emotionManagerView.frame = otherMenuViewFrame;
        //        };
        
        //        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
        //            otherMenuViewFrame = self.shareMenuView.frame;
        //            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
        //            self.shareMenuView.alpha = !hide;
        //            self.shareMenuView.frame = otherMenuViewFrame;
        //        };
        
        
        InputViewAnimation(hide);
        
        //        [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
        //         - self.messageInputView.frame.origin.y];
        //
        //        [self scrollToBottomAnimated:NO];
    } completion:^(BOOL finished) {
        if (hide) {
            //            self.textViewInputViewType = InputViewTypeNormal;
        }
    }];
}




#pragma mark - Previte Method
/**
 *  判断是否允许滚动
 *
 *  @return 返回判断结果
 */
- (BOOL)shouldAllowScroll {
    if (self.isUserScrolling) {
        if ([self.delegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
            && [self.delegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Life Cycle

- (void)setup {

    
    _allowsPanToDismissKeyboard = NO;
    _allowsSendVoice = YES;
    _allowsSendMultiMedia = YES;
    _allowsSendFace = YES;
    // 默认设置用户滚动为NO
    _isUserScrolling = NO;
    
    self.delegate = self;
    self.dataSource = self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
        [self initSubviews];
        [self addObserver];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
    [self initSubviews];
    [self addObserver];
}

- (void)initSubviews {
    
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.view addSubview:self.messageTableView];
    [self.view sendSubviewToBack:self.messageTableView];
    
    // 设置Message TableView 的bottom edg
    [self setTableViewInsetsWithBottomValue:kChatToolBarHeight];
    
    [self.view addSubview:self.messageInputView];
    [self.view bringSubviewToFront:self.messageInputView];

    // 设置整体背景颜色
//    [self setBackgroundColor:[UIColor whiteColor]];
//    [self setBackgroundImage:[UIImage imageNamed:@"bgImage.jpg"]];
}
#pragma mark - 监听
- (void)addObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // KVO 检查contentSize
    [self.messageInputView addObserver:self
                            forKeyPath:@"frame"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.messageInputView removeObserver:self forKeyPath:@"frame"];
    
    _messages = nil;
    _delegate = nil;
    _dataSource = nil;
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
    _messageTableView = nil;
    _messageInputView = nil;
    
    _photographyHelper = nil;
    _locationHelper = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.messageInputView.inputViewState != InputViewStateNormal) {
        
        [self layoutOtherMenuViewHiden:YES];
    }
}



- (void)keyboardWillHide:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    if (self.messageInputView.inputViewState == InputViewStateText) {
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:[self animationOptionsForCurve:curve]
                         animations:^{
                             
                             CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                             
                             // for ipad modal form presentations
                             CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                             if (inputViewFrameY > messageViewFrameBottom)
                                 inputViewFrameY = messageViewFrameBottom;
                             
                             self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                      inputViewFrameY+kbottomCotainerHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height);
                             
                             [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
                              - self.messageInputView.frame.origin.y];
                             
                             if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
                                 [self scrollToBottomAnimated:NO];
                         }
                         completion:nil];
    }
    
}
- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return kNilOptions;
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化消息页面布局

    [[MessageBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - View Rotation

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - RecorderPath Helper Method
/**
 *  获取录音的路径
 *
 *  @return 返回录音的路径
 */
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.m4a", [dateFormatter stringFromDate:now]];
    return recorderPath;
}



#pragma mark - Scroll Message TableView Helper Method
/**
 *  根据bottom的数值配置消息列表的内部布局变化
 *
 *  @param bottom 底部的空缺高度
 */
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.messageTableView.contentInset = insets;
    self.messageTableView.scrollIndicatorInsets = insets;
}
/**
 *  根据底部高度获取UIEdgeInsets常量
 *
 *  @param bottom 底部高度
 *
 *  @return 返回UIEdgeInsets常量
 */
- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

#pragma mark - Message Calculate Cell Height
/**
 *  统一计算Cell的高度方法
 *
 *  @param message   被计算目标消息对象
 *  @param indexPath 被计算目标消息所在的位置
 *
 *  @return 返回计算的高度
 */
- (CGFloat)calculateCellHeightWithMessage:(id <MessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    cellHeight = [MessageTableViewCell calculateCellHeightWithMessage:message displaysTimestamp:displayTimestamp];
    
    return cellHeight;
}





#pragma mark - More的里面item的点击后的方法
/**
 *  根据图片开始发送图片消息
 *
 *  @param photo 目标图片
 */
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    NSLog(@"send photo : %@", photo);
    if ([self.delegate respondsToSelector:@selector(didSendPhoto:fromSender:onDate:)]) {
        [self.delegate didSendPhoto:photo fromSender:self.messageSender onDate:[NSDate date]];
    }
}
/**
 *  根据视频的封面和视频的路径开始发送视频消息
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频的路径
 */
- (void)didSendMessageWithVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath  {
    NSLog(@"send videoPath : %@  videoConverPhoto : %@", videoPath, videoConverPhoto);
    if ([self.delegate respondsToSelector:@selector(didSendVideoConverPhoto:videoPath:fromSender:onDate:)]) {
        [self.delegate didSendVideoConverPhoto:videoConverPhoto videoPath:videoPath fromSender:self.messageSender onDate:[NSDate date]];
    }
}

/**
 *  根据地理位置信息和地理经纬度开始发送地理位置消息
 *
 *  @param geolcations 目标地理信息
 *  @param location    目标地理经纬度
 */
- (void)didSendGeolocationsMessageWithGeolocaltions:(NSString *)geolcations location:(CLLocation *)location {
    NSLog(@"send geolcations : %@", geolcations);
    if ([self.delegate respondsToSelector:@selector(didSendGeoLocationsPhoto:geolocations:location:fromSender:onDate:)]) {
        [self.delegate didSendGeoLocationsPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:geolcations location:location fromSender:self.messageSender onDate:[NSDate date]];
    }
}

#pragma mark - Voice Recording Helper Method

- (void)prepareRecordWithCompletion:(PrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}

/**
 开始录音
 */
- (void)startRecord {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}

/**
 完成录音
 */
- (void)finishRecorded {
    WEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        [weakSelf didSendMessageWithVoice:weakSelf.voiceRecordHelper.recordPath voiceDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}

/**
 想停止录音
 */
- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

/**
 继续录音
 */
- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

/**
 取消录音
 */
- (void)cancelRecord {
    WEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}

#pragma mark - MessageInputViewDelegate
- (void)inputTextViewWillBeginEditing:(MessageTextView *)messageInputTextView {
    
    self.messageInputView.inputViewState = InputViewStateText;
}

/**
 更多里面的点击回调
 */
- (void)messageInputView:(MessageInputView *)inputView didSelecteShareMenuItem:(MoreItemModel *)moreItem atIndex:(NSInteger)index {
    NSLog(@"more title : %@   index:%ld", moreItem.title, (long)index);
    
    WEAKSELF
    void (^PickerMediaBlock)(UIImage *image, NSDictionary *editingInfo) = ^(UIImage *image, NSDictionary *editingInfo) {
        if (image) {
            [weakSelf didSendMessageWithPhoto:image];
        } else {
            if (!editingInfo)
                return ;
            NSString *mediaType = [editingInfo objectForKey: UIImagePickerControllerMediaType];
            NSString *videoPath;
            NSURL *videoUrl;
            if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
                videoUrl = (NSURL*)[editingInfo objectForKey:UIImagePickerControllerMediaURL];
                videoPath = [videoUrl path];
                
                UIImage *thumbnailImage = [MessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath];
                
                [weakSelf didSendMessageWithVideoConverPhoto:thumbnailImage videoPath:videoPath];
            } else {
                [weakSelf didSendMessageWithPhoto:[editingInfo valueForKey:UIImagePickerControllerOriginalImage]];
            }
        }
    };
    switch (index) {
        case 0: {
            [self.photographyHelper showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypePhotoLibrary onViewController:self compled:PickerMediaBlock];
            break;
        }
        case 1: {
            [self.photographyHelper showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypeCamera onViewController:self compled:PickerMediaBlock];
            break;
        }
        case 2: {
            WEAKSELF
            [self.locationHelper getCurrentGeolocationsCompled:^(NSArray *placemarks) {
                CLPlacemark *placemark = [placemarks lastObject];
                if (placemark) {
                    NSDictionary *addressDictionary = placemark.addressDictionary;
                    NSArray *formattedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    NSString *geoLocations = [formattedAddressLines lastObject];
                    if (geoLocations) {
                        [weakSelf didSendGeolocationsMessageWithGeolocaltions:geoLocations location:placemark.location];
                    }
                }
            }];
            break;
        }
        case 4:{
            break;
        }
        default:
            break;
    }
    
}

- (void)didChangeSendVoiceAction:(BOOL)changed {
    
    if (changed) {
        if (self.messageInputView.inputViewState == InputViewStateText)
            return;
        // 在这之前，textViewInputViewType已经不是TextViewTextInputType
        [self layoutOtherMenuViewHiden:YES];
    }
}
- (void)messageInputView:(MessageInputView *)inputView didPressSend:(NSString *)messge {
    NSLog(@"text : %@", messge);
    if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
        [self.delegate didSendText:messge fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//发送贴图
- (void)messageInputView:(MessageInputView *)inputView
       didSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{
    
    if ([self.delegate respondsToSelector:@selector(didSendEmotion:fromSender:onDate:)]) {
        [self.delegate didSendEmotion:chartletId fromSender:self.messageSender onDate:[NSDate date]];
    }
}
/**
 *  根据录音路径开始发送语音消息
 *
 *  @param voicePath        目标语音路径
 *  @param voiceDuration    目标语音时长
 */
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    NSLog(@"send voicePath : %@", voicePath);
    if ([self.delegate respondsToSelector:@selector(didSendVoice:voiceDuration:fromSender:onDate:)]) {
        [self.delegate didSendVoice:voicePath voiceDuration:voiceDuration fromSender:self.messageSender onDate:[NSDate date]];
    }
}

- (void)didSendTextAction:(NSString *)text {
    
    NSLog(@"键盘发送按钮时的 text : %@", text);
    if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
        [self.delegate didSendText:text fromSender:self.messageSender onDate:[NSDate date]];
    }
}

- (void)didSelectedMultipleMediaAction:(BOOL)select {
  
    if (select) {
        [self layoutOtherMenuViewHiden:NO];
    }
}
- (void)didSelectedFaceAction:(BOOL)select {
    
    if (select) {

        [self layoutOtherMenuViewHiden:NO];
    }
}

- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    NSLog(@"prepareRecordingWithCompletion");
    [self prepareRecordWithCompletion:completion];
}

- (void)didStartRecordingVoiceAction {
    NSLog(@"didStartRecordingVoice");
    [self startRecord];
}

- (void)didCancelRecordingVoiceAction {
    NSLog(@"didCancelRecordingVoice");
    [self cancelRecord];
}

- (void)didFinishRecoingVoiceAction {
    NSLog(@"didFinishRecoingVoice");
    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}

- (void)didDragOutsideAction {
    NSLog(@"didDragOutsideAction");
    [self resumeRecord];
}

- (void)didDragInsideAction {
    NSLog(@"didDragInsideAction");
    [self pauseRecord];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(shouldLoadMoreMessagesScrollToTop)]) {
        BOOL shouldLoadMoreMessages = [self.delegate shouldLoadMoreMessagesScrollToTop];
        if (shouldLoadMoreMessages) {
            if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 44) {
                if (!self.loadingMoreMessage) {
                    if ([self.delegate respondsToSelector:@selector(loadMoreMessagesScrollTotop)]) {
                        [self.delegate loadMoreMessagesScrollTotop];
                    }
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isUserScrolling = YES;
    
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.allowsPanToDismissKeyboard && self.messageInputView.inputViewState != InputViewStateNormal && self.messageInputView.inputViewState != InputViewStateText && self.messageInputView.inputViewState != InputViewStateVoice) {
        
        [self layoutOtherMenuViewHiden:YES];

        [self.messageInputView setInputViewState:InputViewStateNormal];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
}

#pragma mark - MessageTableViewController Delegate

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    
    return YES;
}

#pragma mark - MessageTableViewController DataSource

- (id <MessageModel>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return self.messages[indexPath.row];
}

#pragma mark - TableViewDataSource && TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id <MessageModel> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    
    // 如果需要定制复杂的业务UI，那么就实现该DataSource方法
    if ([self.dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:targetMessage:)]) {
        UITableViewCell *tableViewCell = [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath targetMessage:message];
        return tableViewCell;
    }
    
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    static NSString *cellIdentifier = @"MessageTableViewCell";
    
    MessageTableViewCell *messageTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!messageTableViewCell) {
        messageTableViewCell = [[MessageTableViewCell alloc] initWithMessage:message displaysTimestamp:displayTimestamp reuseIdentifier:cellIdentifier];
        messageTableViewCell.delegate = self;
    }
    
    messageTableViewCell.indexPath = indexPath;
    [messageTableViewCell configureCellWithMessage:message displaysTimestamp:displayTimestamp];
    
    if ([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.delegate configureCell:messageTableViewCell atIndexPath:indexPath];
    }
    
    return messageTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <MessageModel> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    
    CGFloat calculateCellHeight = 0;
    
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:targetMessage:)]) {
        calculateCellHeight = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath targetMessage:message];
        return calculateCellHeight;
    } else {
        calculateCellHeight = [self calculateCellHeightWithMessage:message atIndexPath:indexPath];
    }
    
    return calculateCellHeight;
}

#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.messageInputView && [keyPath isEqualToString:@"frame"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}
/**
 *  动态改变TextView的高度
 *
 *  @param messageInputView 被改变的textView对象
 */
- (void)layoutAndAnimateMessageInputTextView:(MessageInputView *)messageInputView {
    
    [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
     - self.messageInputView.frame.origin.y];
    
    [self scrollToBottomAnimated:NO];
}


#pragma mark - getter
- (MessageInputView *)messageInputView {
    // 初始化输入工具条
    if (!_messageInputView) {
        _messageInputView = [[MessageInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kChatToolBarHeight, self.view.frame.size.width, kChatKeyBoardHeight)];
        _messageInputView.allowsSendFace = self.allowsSendFace;
        _messageInputView.allowsSendVoice = self.allowsSendVoice;
        _messageInputView.allowsSendMultiMedia = self.allowsSendMultiMedia;
        _messageInputView.delegate = self;
    }
    return _messageInputView;
}

- (UITableView *)messageTableView {
    if (!_messageTableView) {
        // 初始化message tableView
        _messageTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _messageTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _messageTableView.dataSource = self;
        _messageTableView.delegate = self;
        if (self.allowsPanToDismissKeyboard) {
            _messageTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        }
        _messageTableView.separatorColor = [UIColor clearColor];
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BOOL shouldLoadMoreMessagesScrollToTop = YES;
        if ([self.delegate respondsToSelector:@selector(shouldLoadMoreMessagesScrollToTop)]) {
            shouldLoadMoreMessagesScrollToTop = [self.delegate shouldLoadMoreMessagesScrollToTop];
        }
        if (shouldLoadMoreMessagesScrollToTop) {
            _messageTableView.tableHeaderView = self.headerContainerView;
        }
    }
    return _messageTableView;
}



- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _messages;
}

- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        _headerContainerView.backgroundColor = [UIColor clearColor];
        [_headerContainerView addSubview:self.loadMoreActivityIndicatorView];
    }
    return _headerContainerView;
}
- (UIActivityIndicatorView *)loadMoreActivityIndicatorView {
    if (!_loadMoreActivityIndicatorView) {
        _loadMoreActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadMoreActivityIndicatorView.center = CGPointMake(CGRectGetWidth(_headerContainerView.bounds) / 2.0, CGRectGetHeight(_headerContainerView.bounds) / 2.0);
    }
    return _loadMoreActivityIndicatorView;
}
- (void)setLoadingMoreMessage:(BOOL)loadingMoreMessage {
    _loadingMoreMessage = loadingMoreMessage;
    
    
    if (loadingMoreMessage) {
        [self.loadMoreActivityIndicatorView startAnimating];
    } else {
        [self.loadMoreActivityIndicatorView stopAnimating];
    }
}
- (void)setLoadMoreActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)loadMoreActivityIndicatorViewStyle {
    _loadMoreActivityIndicatorViewStyle = loadMoreActivityIndicatorViewStyle;
    self.loadMoreActivityIndicatorView.activityIndicatorViewStyle = loadMoreActivityIndicatorViewStyle;
}

- (VoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[VoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}

- (PhotographyHelper *)photographyHelper {
    if (!_photographyHelper) {
        _photographyHelper = [[PhotographyHelper alloc] init];
    }
    return _photographyHelper;
}

- (LocationHelper *)locationHelper {
    if (!_locationHelper) {
        _locationHelper = [[LocationHelper alloc] init];
    }
    return _locationHelper;
}

- (VoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
        WEAKSELF
        _voiceRecordHelper = [[VoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            NSLog(@"已经达到最大限制时间了，进入下一步的提示");
            
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = 60;
    }
    return _voiceRecordHelper;
}


@end
