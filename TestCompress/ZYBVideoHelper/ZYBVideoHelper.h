//
//  ZYBVideoHelper.h
//  TestCompress
//
//  Created by Shane on 16/9/27.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface ZYBVideoHelper : NSObject

+ (void)saveVideo:(NSString *)videoPath;
+ (NSString *)savaUserPath;
+ (CGFloat)getfileSize:(NSString *)path;

+ (BOOL)isVideoPortrait:(AVAsset *)asset;
@end
