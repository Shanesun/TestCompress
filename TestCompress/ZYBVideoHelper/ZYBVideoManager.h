//
//  ZYBVideoManager.h
//  TestCompress
//
//  Created by Shane on 16/9/27.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^ExportVideoCompletedBlock)(NSError *error);

@interface ZYBVideoManager : NSObject

+ (AVAssetExportSession *)exportVideoWithAsset:(AVAsset *)asset
                                    presetName:(NSString *)presetName
                              videoComposition:(AVVideoComposition *)videoComposition
                                      audioMix:(AVMutableAudioMix *)audioMix
                                     outputURL:(NSString *)outputPath
                                completedBlock:(ExportVideoCompletedBlock)completedBlock;

@end
