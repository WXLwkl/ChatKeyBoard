//
//  VoiceRecordHelper.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^PrepareRecorderCompletion)();
typedef void(^StartRecorderCompletion)();
typedef void(^StopRecorderCompletion)();
typedef void(^PauseRecorderCompletion)();
typedef void(^ResumeRecorderCompletion)();
typedef void(^CancellRecorderDeleteFileCompletion)();
typedef void(^RecordProgress)(float progress);
typedef void(^PeakPowerForChannel)(float peakPowerForChannel);

@interface VoiceRecordHelper : NSObject

@property (nonatomic, copy) StopRecorderCompletion maxTimeStopRecorderCompletion;
@property (nonatomic, copy) RecordProgress recordProgress;
@property (nonatomic, copy) PeakPowerForChannel peakPowerForChannel;
@property (nonatomic, copy, readonly) NSString *recordPath;
@property (nonatomic, copy) NSString *recordDuration;
@property (nonatomic, assign) float maxRecordTime; //默认 60s 为最大
@property (nonatomic, assign, readonly) NSTimeInterval currentTimeInterval;

- (void)prepareRecordingWithPath:(NSString *)path prepareRecorderCompletion:(PrepareRecorderCompletion)prepareRecorderCompletion;

- (void)startRecordingWithStartRecorderCompletion:(StartRecorderCompletion)startRecorderCompletion;

- (void)pauseRecordingWithPauseRecorderCompletion:(PauseRecorderCompletion)pauseRecorderCompletion;

- (void)resumeRecordingWithResumeRecorderCompletion:(ResumeRecorderCompletion)resumeRecorderCompletion;

- (void)stopRecordingWithStopRecorderCompletion:(StopRecorderCompletion)stopRecorderCompletion;

- (void)cancelledDeleteWithCompletion:(CancellRecorderDeleteFileCompletion)cancelledDeleteCompletion;



@end
