//
//  FaceSourceManager.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/1.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "FaceSourceManager.h"

@implementation FaceSourceManager

//从持久化存储里面加载表情源
+ (NSArray *)loadFaceSource {
    NSMutableArray *subjectArray = [NSMutableArray array];
    
    NSArray *sources = @[@"face", @"emotion",@"face",@"emotion",@"emotion",@"face",@"face",@"emotion",@"face", @"emotion",@"face", @"emotion"];
    
    for (int i = 0; i < sources.count; ++i)
    {
        NSString *plistName = sources[i];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        NSDictionary *faceDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSArray *allkeys = faceDic.allKeys;
        
        FaceSubjectModel *subjectM = [[FaceSubjectModel alloc] init];
        
        if ([plistName isEqualToString:@"face"]) {
            subjectM.faceSize = SubjectFaceSizeKindSmall;
            subjectM.subjectTitle = [NSString stringWithFormat:@"f%d", i];
            subjectM.subjectIcon = @"section0_emotion0";
        }else {
            subjectM.faceSize = SubjectFaceSizeKindMiddle;
            subjectM.subjectTitle = [NSString stringWithFormat:@"e%d", i];
            subjectM.subjectIcon = @"f_static_000";
        }
        
        
        NSMutableArray *modelsArr = [NSMutableArray array];
        
        for (int i = 0; i < allkeys.count; ++i) {
            NSString *name = allkeys[i];
            FaceModel *fm = [[FaceModel alloc] init];
            fm.faceTitle = name;
            fm.faceIcon = [faceDic objectForKey:name];
            [modelsArr addObject:fm];
        }
        subjectM.faceModels = modelsArr;
        
        [subjectArray addObject:subjectM];
    }
    
    
    return subjectArray;
}

@end
