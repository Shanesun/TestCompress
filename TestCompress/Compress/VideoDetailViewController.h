//
//  VideoDetailViewController.h
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoDetailViewController : UIViewController

@property (strong, nonatomic) NSString *videourl;

@property (strong, nonatomic) ALAsset *asset;

@end