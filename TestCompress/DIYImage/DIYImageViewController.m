//
//  DIYImageViewController.m
//  TestCompress
//
//  Created by Shane on 2016/10/10.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "DIYImageViewController.h"
#import "ZYBImageHelper.h"
#import "ZYBVideoHelper.h"
#import "SVProgressHUD.h"

@interface DIYImageViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *imageBgView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundimageView;

@property (strong, nonatomic) UIImageView *maskImageView;
@property (strong, nonatomic) UIButton *maskImageScaleButton;
@property (nonatomic) BOOL isSelectedMaskImage;

@property (nonatomic) CGAffineTransform maskStartTransform;
@property (nonatomic) CGPoint deltaScaleButtonAndMaskImage;
@property (nonatomic) CGFloat maskImageScale;
@property (nonatomic) CGPoint panBeginPoint;
@property (nonatomic) CGPoint scaleBeginPoint;

@end

@implementation DIYImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundimageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgImageView)];
    [self.backgroundimageView addGestureRecognizer:tap];
}

#pragma mark- private meathods
- (void)updateMaskImageCenter:(CGPoint)centerPoint
{
    self.maskImageView.center = centerPoint;
    self.maskImageScaleButton.center = CGPointMake(self.deltaScaleButtonAndMaskImage.x+self.maskImageView.center.x, self.deltaScaleButtonAndMaskImage.y+self.maskImageView.center.y);
}

- (void)updateScaleCenter:(CGPoint)centerPoint
{
    CGPoint maskCenter = self.maskImageView.center;
    // 两个中心点间距 平方
    CGFloat distance = fabs(centerPoint.x - maskCenter.x)*fabs(centerPoint.x - maskCenter.x) + fabs(centerPoint.y - maskCenter.y)*fabs(centerPoint.y - maskCenter.y);
    // 计算 缩放后的宽度和高度。
    CGFloat newMaskHeight = sqrt((distance*4)/(self.maskImageScale*self.maskImageScale + 1));
    CGFloat newMaskWidth = newMaskHeight * self.maskImageScale;
    self.maskImageView.bounds = CGRectMake(0, 0, newMaskWidth, newMaskHeight);
    
    // 计算 旋转角度
    CGFloat angle = [self originPoint:self.maskImageView.center startPoint:self.scaleBeginPoint endPoint:centerPoint];
    NSLog(@" originPoint:%@, startPoint:%@, endPoint:%@, angle:%f",NSStringFromCGPoint(self.maskImageView.center),NSStringFromCGPoint(self.scaleBeginPoint),NSStringFromCGPoint(centerPoint), angle);

    self.maskImageView.transform = CGAffineTransformRotate(self.maskStartTransform, angle);
    
    self.maskImageScaleButton.center = centerPoint;
}

- (CGFloat)originPoint:(CGPoint)originPoint startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    double angleStart = atan2f(startPoint.y - originPoint.y, startPoint.x - originPoint.x);
    double angleEnd = atan2f(endPoint.y - originPoint.y, endPoint.x - originPoint.x);
    double angleDelta = angleEnd - angleStart;
    return angleDelta;
}

#pragma mark recognizer
- (void)tapBgImageView
{
    self.isSelectedMaskImage = NO;
}

- (void)tapMaskImageView
{
    self.isSelectedMaskImage = YES;
}

- (void)panMaskImageView:(UIPanGestureRecognizer *)recognizer
{
    if (!self.isSelectedMaskImage) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.panBeginPoint = recognizer.view.center;
        self.deltaScaleButtonAndMaskImage = CGPointMake(self.maskImageScaleButton.center.x-self.panBeginPoint.x, self.maskImageScaleButton.center.y-self.panBeginPoint.y);
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
       CGPoint panOffset = [recognizer translationInView:[recognizer.view superview]];
        
        CGPoint newCenterPoint = CGPointMake(self.panBeginPoint.x+panOffset.x, self.panBeginPoint.y+panOffset.y);
        [self updateMaskImageCenter:newCenterPoint];
        
        NSLog(@"begin: %@, offset: %@, newCneter: %@", NSStringFromCGPoint(self.panBeginPoint), NSStringFromCGPoint(panOffset), NSStringFromCGPoint(self.maskImageView.center));
    }
}

- (void)panScale:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"--- Began -----");
        self.scaleBeginPoint = recognizer.view.center;
        self.maskStartTransform = self.maskImageView.transform;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"--- Changed -----");
        CGPoint panOffset = [recognizer translationInView:[recognizer.view superview]];
        CGPoint newCenterPoint = CGPointMake(self.scaleBeginPoint.x+panOffset.x, self.scaleBeginPoint.y+panOffset.y);
        NSLog(@"---- panoffset:%@,center:%@",NSStringFromCGPoint(panOffset),NSStringFromCGPoint(newCenterPoint));
        [self updateScaleCenter:newCenterPoint];
    }
}

#pragma mark- IBAction
- (IBAction)addMaskImageClicked:(id)sender
{
    self.maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 32)];
    self.maskImageView.userInteractionEnabled = YES;
    self.maskImageView.clipsToBounds = NO;
    self.maskImageView.image = [UIImage imageNamed:@"麦克雷帽"];
    self.maskImageView.center = self.backgroundimageView.center;
    [self.imageBgView addSubview:self.maskImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskImageView)];
    [self.maskImageView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMaskImageView:)];
    [self.maskImageView addGestureRecognizer:pan];
    
    self.maskImageScale = 85.0/32.0;
}

- (IBAction)addImageButtonClicked:(id)sender
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)savaImageClicked:(id)sender
{
    if (!self.backgroundimageView.image) return;
    
   UIImage *composeImage = [ZYBImageHelper composeNewImage:self.backgroundimageView overlayImage:self.maskImageView];
    
    [ZYBImageHelper saveImageToPhotoAlbum:composeImage finishBlock:^(NSError *error) {
        if (!error) {
            [SVProgressHUD showInfoWithStatus:@"保存成功"];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"保存失败"];
        }
    }];
}

- (IBAction)increaseImageSizeClicked:(id)sender
{
    
}

- (IBAction)reduceImageSizeClicked:(id)sender
{
    
}
#pragma mark- image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    self.backgroundimageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- setters and getters 
- (void)setIsSelectedMaskImage:(BOOL)isSelectedMaskImage
{
    _isSelectedMaskImage = isSelectedMaskImage;
    if (isSelectedMaskImage) {
        self.maskImageView.layer.borderColor = [UIColor blueColor].CGColor;
        self.maskImageView.layer.borderWidth = 2;
        
        if (!self.maskImageScaleButton) {
            self.maskImageScaleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
            [self.maskImageScaleButton setImage:[UIImage imageNamed:@"diy_scale"] forState:UIControlStateNormal];
            [self.maskImageScaleButton setImage:[UIImage imageNamed:@"diy_scale"] forState:UIControlStateHighlighted];
            self.maskImageScaleButton.contentMode = UIViewContentModeScaleAspectFit;
            self.maskImageScaleButton.userInteractionEnabled = YES;
            self.maskImageScaleButton.center = CGPointMake(CGRectGetMaxX(self.maskImageView.frame), CGRectGetMaxY(self.maskImageView.frame));
            [self.imageBgView addSubview:self.maskImageScaleButton];
            
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panScale:)];
            [self.maskImageScaleButton addGestureRecognizer:pan];
        }
        else{
            self.maskImageScaleButton.hidden = NO;
        }

    }
    else{
        self.maskImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.maskImageView.layer.borderWidth = 0;
        
        self.maskImageScaleButton.hidden = YES;
    }
}


@end
