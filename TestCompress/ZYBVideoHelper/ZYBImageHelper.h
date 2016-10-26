//
//  ZYBImageHelper.h
//  TestCompress
//
//  Created by Shane on 2016/10/11.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZYBImageHelper : NSObject

+ (UIImage *)composeNewImage:(UIImageView *)orignImage overlayImage:(UIImageView *)overlayImage;

+ (void)saveImageToPhotoAlbum:(UIImage *)image finishBlock:(void (^)(NSError *error)) finishBlock;


/**
 缩放图片 到 制定分辨率

 @param orignImage origin image
 @param resolution you want crop resolution

 @return new image
 */
+ (UIImage *)cropImage:(UIImage *)orignImage toSize:(CGSize)resolution;

@end
