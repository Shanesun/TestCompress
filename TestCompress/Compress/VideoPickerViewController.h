//
//  VideoPickerViewController.h
//  TestCompress
//
//  Created by Shane on 16/9/21.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SelectVideoBlock)(ALAsset *asset);

@interface VideoPickerViewController : UIViewController

@property (copy, nonatomic) SelectVideoBlock selectBlock;

@end
