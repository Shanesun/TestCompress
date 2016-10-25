//
//  SSImageViewerViewController.m
//  TestCompress
//
//  Created by Shane on 2016/10/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "SSImageViewerViewController.h"

#define kViewBounds CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)

@interface SSImageViewerViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomNC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopNC;


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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self adaptZoomScrollView:self.scrollView
             scrollViewBounds:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)
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
- (void)adaptZoomScrollView:(UIScrollView *)scrollView scrollViewBounds:(CGRect)scrollViewBounds byImage:(UIImage *)image
{
    float minZoom = MIN(scrollViewBounds.size.width / image.size.width,
                        scrollViewBounds.size.height / image.size.height);
    
    if (minZoom > 1) minZoom = 1;
    
    scrollView.minimumZoomScale = minZoom;
    scrollView.zoomScale = minZoom;
    
}
// 更新 约束
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
