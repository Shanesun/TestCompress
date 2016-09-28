//
//  ZYBVideoManager.m
//  TestCompress
//
//  Created by Shane on 16/9/27.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "ZYBVideoManager.h"

@implementation ZYBVideoManager

+ (AVAssetExportSession *)exportVideoWithAsset:(AVAsset *)asset
                                    presetName:(NSString *)presetName
                              videoComposition:(AVVideoComposition *)videoComposition
                                     outputURL:(NSString *)outputPath
                                completedBlock:(ExportVideoCompletedBlock)completedBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        [fileManager removeItemAtPath:outputPath error:nil];
    }
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    exportSession.videoComposition = videoComposition;
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath];
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
//                [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                if (completedBlock) {
                    completedBlock(nil);
                }

                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",exportSession.error);
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",exportSession.error);
            default:
                if (completedBlock) {
                    if (!exportSession.error) {
                         NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-101 userInfo:nil];
                        completedBlock(error);
                    }
                    else{
                        completedBlock(exportSession.error);
                    }
                }
                break;
        }
    }];
    
    return exportSession;
}

@end
