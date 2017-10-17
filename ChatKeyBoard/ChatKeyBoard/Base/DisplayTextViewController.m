//
//  DisplayTextViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "DisplayTextViewController.h"

@interface DisplayTextViewController ()

@property (nonatomic, weak) UITextView *displayTextView;

@end

@implementation DisplayTextViewController

- (UITextView *)displayTextView {
    if (!_displayTextView) {
        UITextView *displayTextView = [[UITextView alloc] initWithFrame:self.view.frame];
        displayTextView.font = [UIFont systemFontOfSize:16.0f];
        displayTextView.textColor = [UIColor blackColor];
        displayTextView.userInteractionEnabled = YES;
        displayTextView.editable = NO;
        displayTextView.backgroundColor = [UIColor clearColor];
        displayTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        [self.view addSubview:displayTextView];
        _displayTextView = displayTextView;
    }
    return _displayTextView;
}

- (void)setMessage:(id<MessageModel>)message {
    _message = message;
    self.displayTextView.text = [message text];
}
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"TextDetail", @"MessageDisplayKitString", @"文本消息");
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.displayTextView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
