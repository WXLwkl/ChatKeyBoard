//
//  DisplayMediaViewController.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/10/16.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface DisplayMediaViewController : UIViewController

@property (nonatomic, strong) id <MessageModel> message;

@end
