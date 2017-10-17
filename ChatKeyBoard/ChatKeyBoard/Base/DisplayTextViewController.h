//
//  DisplayTextViewController.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface DisplayTextViewController : UIViewController

@property (nonatomic, strong) id <MessageModel> message;

@end
