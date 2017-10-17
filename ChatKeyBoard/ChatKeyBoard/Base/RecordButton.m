//
//  RecordButton.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "RecordButton.h"

#define kGetColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@implementation RecordButton

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.hidden = YES;
        self.backgroundColor = kGetColor(247, 247, 247);
        
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        self.layer.cornerRadius = 5.0f;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
        
        [self addTarget:self action:@selector(recordTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(recordTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(recordTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(recordTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(recordTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(recordTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(recordTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    }
    return self;
}

- (void)setButtonStateWithRecording
{
    self.backgroundColor = kGetColor(214, 215, 220); //214,215,220
    [self setTitle:@"松开 结束" forState:UIControlStateNormal];
}

- (void)setButtonStateWithNormal
{
    self.backgroundColor = kGetColor(247, 247, 247);
    [self setTitle:@"按住 说话" forState:UIControlStateNormal];
}


#pragma mark -- 事件方法回调
- (void)recordTouchDown
{
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchDownAction) {
        self.recordTouchDownAction(self);
    }
}

- (void)recordTouchUpOutside
{
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchUpOutsideAction) {
        self.recordTouchUpOutsideAction(self);
    }
}

- (void)recordTouchUpInside
{
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchUpInsideAction) {
        self.recordTouchUpInsideAction(self);
    }
}

- (void)recordTouchDragEnter
{
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchDragEnterAction) {
        self.recordTouchDragEnterAction(self);
    }
}

- (void)recordTouchDragInside
{
    
    
    
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchDragInsideAction) {
        self.recordTouchDragInsideAction(self);
    }
}

- (void)recordTouchDragOutside
{
    
    
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchDragOutsideAction) {
        self.recordTouchDragOutsideAction(self);
    }
}

- (void)recordTouchDragExit
{
    
    NSLog(@"%s", __FUNCTION__);
    if (self.recordTouchDragExitAction) {
        self.recordTouchDragExitAction(self);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside: point withEvent: event];
    
    if (inside && !self.highlighted)
    {
        //self.highlighted = YES;
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
    
    return inside;
}

@end
