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

@end
