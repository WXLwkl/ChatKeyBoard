//
//  FirstViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "Header.h"

#import "FirstViewController.h"



@interface FirstViewController ()


@property (weak, nonatomic) IBOutlet UILabel *voiceState;
@property (weak, nonatomic) IBOutlet UILabel *sendText;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"评论键盘";
    

    
}

- (IBAction)switchBar:(UISwitch *)sender {
    
}
- (IBAction)switchVoice:(UISwitch *)sender {
    
}

- (IBAction)switchFace:(UISwitch *)sender {
    
}

- (IBAction)switchMore:(UISwitch *)sender {
    
}
//开始评论
- (IBAction)beginComment:(id)sender {
    
}
//评论结束
- (IBAction)closekeyboard:(id)sender {
    
    
}





@end
