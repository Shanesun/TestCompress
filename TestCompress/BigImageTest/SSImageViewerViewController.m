//
//  SSImageViewerViewController.m
//  TestCompress
//
//  Created by Shane on 2016/10/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "SSImageViewerViewController.h"

#import "ZYBImageHelper.h"
#import "SVProgressHUD.h"

#define kViewBounds CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)

@interface SSImageViewerViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopNC;

@property (nonatomic) BOOL hadLoadImage;


@property (strong, nonatomic) UIImage *showImage;

@end

@implementation SSImageViewerViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _showImage = image;
    }
    return self;
}

- (void)configUI
{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 44)];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"压缩" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(compressButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
    [self adaptZoomScrollView:self.scrollView
             scrollViewBounds:kViewBounds
                      byImage:self.showImage];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSTimeInterval start = CACurrentMediaTime();
        
        NSLog(@"start show -----");
        // 这里参数 使用1，图片原始尺寸
        UIGraphicsBeginImageContextWithOptions(self.showImage.size, YES, 1);
        [self.showImage drawInRect:CGRectMake(0, 0, self.showImage.size.width, self.showImage.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSTimeInterval nowt = CACurrentMediaTime();
          NSLog(@"load show -----%f",nowt-start);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hadLoadImage = YES;
            self.photoImageView.image = newImage;
            NSTimeInterval now = CACurrentMediaTime();
            
            NSLog(@"show -----%f",now-start);
        });
    });

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}

#pragma mark- private meathods

- (void)compressButtonClicked:(UIBarButtonItem *)sender
{
    if (!self.hadLoadImage) return;
    
    switch (self.compressType) {
        case CompressTypeSize:
        {
            float compressValue = self.compressValue.floatValue;
            [SVProgressHUD showWithStatus:@"同步循环压缩中..."];
            float compressFactor = 0.9;
            NSData *data = UIImageJPEGRepresentation(self.showImage, compressFactor);
            NSLog(@"----- 原始大小：%fmb",data.length/(1024.0*1024.0));
            
            NSTimeInterval compressStart = CACurrentMediaTime();
            while (compressFactor > 0 && data.length/(1024.0*1024.0) > compressValue) {
                @autoreleasepool {
                    compressFactor = compressFactor - 0.1;
                    NSTimeInterval start = CACurrentMediaTime();
                    data = UIImageJPEGRepresentation(self.showImage, compressFactor);
                    NSTimeInterval now = CACurrentMediaTime();
                    NSLog(@"----- 压缩系数：%f,  压缩后的大小：%fmb, -- 耗时：%fs",compressFactor,data.length/(1024.0*1024.0),(now-start));
                }
            }
            NSTimeInterval compressDone = CACurrentMediaTime();
            NSLog(@"=========压缩后的大小：%fmb, 压缩处理时间：%fs",data.length/(1024.0*1024.0),(compressDone-compressStart));
            
            NSTimeInterval saveStart = CACurrentMediaTime();
            [ZYBImageHelper saveImageToPhotoAlbum:[UIImage imageWithData:data] finishBlock:^(NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"保存失败"];
                }
                
                [SVProgressHUD dismiss];
                
                NSTimeInterval saveDone = CACurrentMediaTime();
                NSLog(@"--------保存照片：%fs",(saveDone-saveStart));
                
                NSString *promatString = [[NSString alloc] initWithFormat:@"压缩后的大小：%fmb\n压缩用时：%fs\n保存到相册用时：%fs",data.length/(1024.0*1024.0),(compressDone-compressStart),(saveDone-saveStart)];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已经保存到相册" message:promatString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }];
            break;
        }
        case CompressTypeFactor:
            break;
            
        case CompressTypeMixCompress:
        {
            UIImage *cropImage = [self cropImage:self.showImage];
            float tmp = 0.45;
            NSData *data = UIImageJPEGRepresentation(cropImage, tmp);
            NSLog(@"---压缩：%fmb",data.length/(1024.0*1024.0));
                 [ZYBImageHelper saveImageToPhotoAlbum:[UIImage imageWithData:data] finishBlock:^(NSError *error) {
                     [SVProgressHUD showInfoWithStatus:@"保存成功"];
                 }];
            
            break;
        }
    }
}

- (UIImage *)cropImage:(UIImage *)orignImage
{
    UIImage *newImage = orignImage;
    CGSize cropResolution = CGSizeZero;
    
    CGFloat max = 0.0;
    CGFloat scale = 0.0;
    
    // 分辨率小于 1280.0x1280.0
    if (newImage.size.width <= 1280.0 &&
        newImage.size.height <= 1280.0) {
        return orignImage;
    }
    
    if (newImage.size.width > newImage.size.height) {
        max = newImage.size.width;
        scale = newImage.size.width/1280.0;
        
        cropResolution.width = 1280.0;
        cropResolution.height = newImage.size.height / scale;
    }
    else{
        max = newImage.size.height;
        scale = newImage.size.height/1280.0;
        
        cropResolution.height = 1280.0;
        cropResolution.width = newImage.size.width / scale;
    }
    
    newImage = [ZYBImageHelper cropImage:newImage toSize:cropResolution];
    
    return newImage;
}

#pragma mark 缩放
- (void)adaptZoomScrollView:(UIScrollView *)scrollView scrollViewBounds:(CGRect)scrollViewBounds byImage:(UIImage *)image
{
    float minZoom = MIN(scrollViewBounds.size.width / image.size.width,
                        scrollViewBounds.size.height / image.size.height);
    
    if (minZoom > 1) minZoom = 1;
    
    scrollView.minimumZoomScale = minZoom;
    scrollView.zoomScale = minZoom;
    
}

// 更新 约束，保持时刻居中
- (void)updateConstraints
{
    // 设置 imageView 上 左 下 右位置，使其居中
    float imageWidth = self.showImage.size.width;
    float imageHeight = self.showImage.size.height;
    
    float viewWidth = kViewBounds.size.width;
    float viewHeight = kViewBounds.size.height;
    
    float hPadding = (viewWidth - self.scrollView.zoomScale * imageWidth) / 2;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (viewHeight - self.scrollView.zoomScale * imageHeight) / 2;
    if (vPadding < 0) vPadding = 0;
    
    self.imageViewLeadingNC.constant = hPadding;
    self.imageViewTrailingNC.constant = hPadding;
    
    self.imageViewTopNC.constant = vPadding;
    self.imageViewBottomNC.constant = vPadding;
}

#pragma mark- scrollView 缩放
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateConstraints];
    
    NSLog(@"缩放:s:%f",scrollView.zoomScale);
}

@end
