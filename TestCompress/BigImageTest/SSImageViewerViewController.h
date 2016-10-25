//
//  SSImageViewerViewController.h
//  TestCompress
//
//  Created by Shane on 2016/10/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CompressTypeSize = 0, // 指定 压缩后大小
    CompressTypeFactor
} CompressType;

@interface SSImageViewerViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic) CompressType compressType;
@property (strong, nonatomic) NSNumber *compressValue;

@end
