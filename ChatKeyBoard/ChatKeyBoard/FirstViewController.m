//
//  FirstViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "FirstViewController.h"
#import "ChatKeyBoard.h"

#import "MoreItemModel.h"
#import "ChatToolBarItemModel.h"

@interface FirstViewController ()<ChatKeyBoardDelegate, ChatKeyBoardDataSource>
/** 聊天键盘 */
@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard;
@property (weak, nonatomic) IBOutlet UILabel *voiceState;
@property (weak, nonatomic) IBOutlet UILabel *sendText;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"评论键盘";
    
    self.chatKeyBoard = [ChatKeyBoard keyBoard];
    self.chatKeyBoard.delegate = self;
    self.chatKeyBoard.dataSource = self;
    self.chatKeyBoard.keyBoardStyle = KeyBoardStyleComment;
    self.chatKeyBoard.placeHolder = @"评论";
    [self.view addSubview:self.chatKeyBoard];
    
}
- (NSArray<MoreItemModel *> *)chatKeyBoardMorePanelItems {
    
    MoreItemModel *item1 = [MoreItemModel moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItemModel *item2 = [MoreItemModel moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItemModel *item3 = [MoreItemModel moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    MoreItemModel *item4 = [MoreItemModel moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItemModel *item5 = [MoreItemModel moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItemModel *item6 = [MoreItemModel moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    MoreItemModel *item7 = [MoreItemModel moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItemModel *item8 = [MoreItemModel moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItemModel *item9 = [MoreItemModel moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    return @[item1, item2, item3, item4, item5, item6, item7, item8, item9];
}
- (NSArray<ChatToolBarItemModel *> *)chatKeyBoardToolbarItems {
    ChatToolBarItemModel *item1 = [ChatToolBarItemModel barItemWithKind:BarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItemModel *item2 = [ChatToolBarItemModel barItemWithKind:BarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItemModel *item3 = [ChatToolBarItemModel barItemWithKind:BarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItemModel *item4 = [ChatToolBarItemModel barItemWithKind:BarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}
- (NSArray<FaceSubjectModel *> *)chatKeyBoardFacePanelSubjectItems {
//    return [FaceSourceManager loadFaceSource];
    return nil;
}

- (IBAction)switchBar:(UISwitch *)sender {
    self.chatKeyBoard.allowSwitchBar = sender.on;
}
- (IBAction)switchVoice:(UISwitch *)sender
{
    self.chatKeyBoard.allowVoice = sender.on;
}

- (IBAction)switchFace:(UISwitch *)sender
{
    self.chatKeyBoard.allowFace = sender.on;
}

- (IBAction)switchMore:(UISwitch *)sender
{
    self.chatKeyBoard.allowMore = sender.on;
}

- (IBAction)beginComment:(id)sender {
    [self.chatKeyBoard beginComment];
}
- (IBAction)closekeyboard:(id)sender {
    
    [self.chatKeyBoard endComment];
}



#pragma mark -- 语音状态
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard{
    
    self.voiceState.text = @"正在录音";
}
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard
{
    self.voiceState.text = @"已经取消录音";
}
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard
{
    self.voiceState.text = @"已经完成录音";
}
- (void)chatKeyBoardWillCancelRecoding:(ChatKeyBoard *)chatKeyBoard
{
    self.voiceState.text = @"将要取消录音";
}
- (void)chatKeyBoardContineRecording:(ChatKeyBoard *)chatKeyBoard
{
    self.voiceState.text = @"继续录音";
}


#pragma mark -- 表情

- (void)chatKeyBoardFacePicked:(ChatKeyBoard *)chatKeyBoard faceSize:(NSInteger)faceSize faceName:(NSString *)faceName delete:(BOOL)isDelete;
{
    
}
- (void)chatKeyBoardAddFaceSubject:(ChatKeyBoard *)chatKeyBoard
{
//    FaceStoreViewController *faceStore = [[FaceStoreViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:faceStore];
//    [self presentViewController:nav animated:YES completion:nil];
}
- (void)chatKeyBoardSetFaceSubject:(ChatKeyBoard *)chatKeyBoard
{
//    FaceManagerCenterViewController *faceManage = [[FaceManagerCenterViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:faceManage];
//    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 更多
- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index
{
    NSString *message = [NSString stringWithFormat:@"选择的ItemIndex %zd", index];
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"ItemIndex" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertV show];
}

#pragma mark -- 发送文本
- (void)chatKeyBoardSendText:(NSString *)text {
    self.sendText.text = text;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
