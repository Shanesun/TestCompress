//
//  ZYBImageHelper.m
//  TestCompress
//
//  Created by Shane on 2016/10/11.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "ZYBImageHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ZYBImageHelper

+ (UIImage *)composeNewImage:(UIImageView *)orignImage overlayImage:(UIImageView *)overlayImage
{
    UIImage *newImage = nil;
    
    CGSize size = orignImage.image.size;
    UIGraphicsBeginImageContext(size);
    
    [orignImage.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [overlayImage.image drawInRect:overlayImage.frame];
    
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    newImage = resultingImage;
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)saveImageToPhotoAlbum:(UIImage *)image finishBlock:(void (^)(NSError *error)) finishBlock
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}
@end
