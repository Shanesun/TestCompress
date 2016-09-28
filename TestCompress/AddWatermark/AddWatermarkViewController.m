//
//  AddWatermarkViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/26.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "AddWatermarkViewController.h"
#import "VideoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYBVideoManager.h"
#import "ZYBVideoHelper.h"
#import "SVProgressHUD.h"

@interface AddWatermarkViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic)AVPlayerLayer *playerLayer;

@property (assign, nonatomic) BOOL isPlay;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) CALayer *watermarkLayer;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVMutableVideoComposition *videoComposition;
@property (strong, nonatomic) AVAssetExportSession *exportSession;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) CIFilter *filter;

@end

@implementation AddWatermarkViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.player = [[AVPlayer alloc] init];
}

- (IBAction)selecteVideoClicked:(id)sender {
    VideoPickerViewController *videoVc = [VideoPickerViewController new];
    videoVc.selectBlock = ^(ALAsset *asset){
        [self displayVideoWithAsset:asset];
    };
    [self.navigationController pushViewController:videoVc animated:YES];
}

- (IBAction)addWatermarkClicked:(id)sender {
    AVAssetTrack *assetVideoTrack = nil;
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    self.watermarkLayer = [self watermarkLayerForsize:self.playerLayer.videoRect.size];
    if(self.watermarkLayer) {
        self.watermarkLayer.position = CGPointMake([[self playerView] bounds].size.width/2, [[self playerView] bounds].size.height/2);
        [[[self playerView] layer] addSublayer:self.watermarkLayer];
    }
}

- (IBAction)exportVideoAndSave:(UIBarButtonItem *)sender
{

    if (self.watermarkLayer) {
        AVAssetTrack *assetVideoTrack = nil;
        if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
            assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
        }
        CGSize videoSize = assetVideoTrack.naturalSize;
        if ([ZYBVideoHelper isVideoPortrait:self.asset]) {
            NSLog(@"video is portrait ");
            videoSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        };
        self.videoComposition.renderSize = videoSize;
        
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        
        CALayer *exportWatermarkLayer = [self outputWatermarkLayerForsize:self.videoComposition.renderSize];
        exportWatermarkLayer.position = CGPointMake(self.videoComposition.renderSize.width/2, self.videoComposition.renderSize.height/2);
        [parentLayer addSublayer:exportWatermarkLayer];
        
        self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }

    

    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePregress) userInfo:nil repeats:YES];
   
    NSString *presetName = AVAssetExportPresetMediumQuality;
    if (sender.tag == 0) {
        presetName = AVAssetExportPresetHighestQuality;
    }
    else{
        presetName = AVAssetExportPresetMediumQuality;
    }
    self.exportSession = [ZYBVideoManager exportVideoWithAsset:self.asset presetName:presetName videoComposition:self.videoComposition outputURL:[[ZYBVideoHelper savaUserPath] stringByAppendingPathComponent:self.fileName] completedBlock:^(NSError *error) {
        [self.timer invalidate];
        self.timer = nil;
        [SVProgressHUD dismiss];
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [ZYBVideoHelper saveVideo:[[ZYBVideoHelper savaUserPath] stringByAppendingPathComponent:self.fileName]];
        });
        
    }];
}

- (void)updatePregress
{
     [SVProgressHUD showProgress:self.exportSession.progress];
}

#pragma mark- private meathods
- (void)displayVideoWithAsset:(ALAsset *)asset
{
    self.fileName = [[asset defaultRepresentation] filename];
    self.asset = [AVAsset assetWithURL:[[asset defaultRepresentation] url]];
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.asset];
    self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    self.videoComposition.renderSize = assetVideoTrack.naturalSize;
    
    AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [newPlayerLayer setFrame:self.playerView.layer.bounds];
    [self.playerView.layer addSublayer:newPlayerLayer];
    [self setPlayerLayer:newPlayerLayer];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (IBAction)playPauseClicked:(UIBarButtonItem *)sender {
    self.isPlay = !self.isPlay;

    if (self.isPlay) {
        sender.style = UIBarButtonSystemItemPause;
        [[self player] seekToTime:CMTimeMakeWithSeconds(0, 1)];
        [self.player play];
    }
    else{
        sender.style = UIBarButtonSystemItemPlay;
        [self.player pause];
    }
}
- (IBAction)addFilterClicked:(id)sender
{
    self.filter = [CIFilter filterWithName:@"CISepiaTone"];
    
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:self.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CIImage *source = [request.sourceImage imageByClampingToExtent];
        // Clamp to avoid blurring transparent pixels at the image edges
        [self.filter setValue:source forKey:kCIInputImageKey];
        
        // Vary filter parameters based on video timing
        //        long long seconds = CMTimeGetSeconds(request.compositionTime);
        //        [filter setValue:@(seconds * 10.0) forKey:kCIInputRadiusKey];
        
        // Crop the blurred output to the bounds of the original image
        CIImage *output = [[self.filter outputImage] imageByCroppingToRect:request.sourceImage.extent];
        
        // Provide the filter output to the composition
        [request finishWithImage:output context:nil];
    }];
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    playerItem.videoComposition = self.videoComposition;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    if(self.watermarkLayer) {
        self.watermarkLayer.position = CGPointMake([[self playerView] bounds].size.width/2, [[self playerView] bounds].size.height/2);
        [[[self playerView] layer] addSublayer:self.watermarkLayer];
    }
}

#pragma mark- helper

- (CALayer *)watermarkLayerForsize:(CGSize)videoSize
{
    CALayer *watermarkLayer = [CALayer layer];
    watermarkLayer.contents = (id)[UIImage imageNamed:@"watermark"].CGImage;
    watermarkLayer.contentsGravity = kCAGravityResizeAspect;
    watermarkLayer.frame = CGRectMake(0, 0, videoSize.width*0.487,videoSize.height*0.119);
    
    return watermarkLayer;
}
- (CALayer *)outputWatermarkLayerForsize:(CGSize)videoSize
{
    CALayer *watermarkLayer = [CALayer layer];
    watermarkLayer.contents = (id)[UIImage imageNamed:@"watermark"].CGImage;
    watermarkLayer.contentsGravity = kCAGravityResizeAspect;
    watermarkLayer.frame = CGRectMake(0, 0, videoSize.width*0.487,videoSize.height*0.119);
    
    return watermarkLayer;
}


@end
