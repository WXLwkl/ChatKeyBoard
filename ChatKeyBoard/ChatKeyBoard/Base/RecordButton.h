//
//  RecordButton.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordButton;

typedef void (^RecordTouchDown)         (RecordButton *recordButton);
typedef void (^RecordTouchUpOutside)    (RecordButton *recordButton);
typedef void (^RecordTouchUpInside)     (RecordButton *recordButton);
typedef void (^RecordTouchDragEnter)    (RecordButton *recordButton);
typedef void (^RecordTouchDragInside)   (RecordButton *recordButton);
typedef void (^RecordTouchDragOutside)  (RecordButton *recordButton);
typedef void (^RecordTouchDragExit)     (RecordButton *recordButton);

@interface RecordButton : UIButton

@property (nonatomic, copy) RecordTouchDown         recordTouchDownAction;
@property (nonatomic, copy) RecordTouchUpOutside    recordTouchUpOutsideAction;
@property (nonatomic, copy) RecordTouchUpInside     recordTouchUpInsideAction;
@property (nonatomic, copy) RecordTouchDragEnter    recordTouchDragEnterAction;
@property (nonatomic, copy) RecordTouchDragInside   recordTouchDragInsideAction;
@property (nonatomic, copy) RecordTouchDragOutside  recordTouchDragOutsideAction;
@property (nonatomic, copy) RecordTouchDragExit     recordTouchDragExitAction;

- (void)setButtonStateWithRecording;
- (void)setButtonStateWithNormal;


@end
