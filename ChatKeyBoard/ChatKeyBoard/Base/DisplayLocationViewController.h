//
//  DisplayLocationViewController.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MessageModel.h"

@interface DisplayLocationViewController : UIViewController

@property (nonatomic, strong) id <MessageModel> message;

@end
