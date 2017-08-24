//
//  OfficialAccountToolbar.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef void (^SWITCHACTION) ();
typedef void(^SwitchAction)();

@interface OfficialAccountToolbar : UIView

@property (nonatomic, copy) SwitchAction switchAction;

@end
