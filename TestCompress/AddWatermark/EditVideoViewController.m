//
//  AddWatermarkViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/26.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "EditVideoViewController.h"
#import "VideoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYBVideoManager.h"
#import "ZYBVideoHelper.h"
#import "SVProgressHUD.h"

@interface EditVideoViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *editVideoButtonsArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *heighCompressButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *middleCompressButton;


@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic)AVPlayerLayer *playerLayer;

@property (assign, nonatomic) BOOL isPlay;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) CALayer *watermarkLayer;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVMutableVideoComposition *videoComposition;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVMutableAudioMix *audioMix;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) CIFilter *filter;

@end

@implementation EditVideoViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    self.player = [[AVPlayer alloc] init];
}

- (void)configUI
{
    [self editButtonsEnable:NO];
}

- (void)editButtonsEnable:(BOOL)enable
{
    for (UIButton *button in self.editVideoButtonsArray) {
        if (enable) {
            button.enabled = YES;
            button.alpha = 1;
        }
        else{
            button.enabled = NO;
            button.alpha = 0.5;
        }
    }
    if (enable) {
        self.heighCompressButton.enabled = YES;
        self.middleCompressButton.enabled = YES;
    }
    else{
        self.heighCompressButton.enabled = NO;
        self.middleCompressButton.enabled = NO;
    }

}

- (IBAction)selecteVideoClicked:(id)sender {
    VideoPickerViewController *videoVc = [VideoPickerViewController new];
    videoVc.selectBlock = ^(ALAsset *asset){
        [self displayVideoWithAsset:asset];
         [self editButtonsEnable:YES];
    };
    [self.navigationController pushViewController:videoVc animated:YES];
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
    
    if (!self.playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.playerLayer setFrame:self.playerView.layer.bounds];
        [self.playerView.layer addSublayer:self.playerLayer];
        [self setPlayerLayer:self.playerLayer];
    }

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

#pragma mark- 视频操作
- (IBAction)addWatermarkClicked:(id)sender {

    self.watermarkLayer = [self watermarkLayerForsize:self.playerLayer.videoRect.size];
    if(self.watermarkLayer) {
        self.watermarkLayer.position = CGPointMake([[self playerView] bounds].size.width/2, [[self playerView] bounds].size.height/2);
        [[[self playerView] layer] addSublayer:self.watermarkLayer];
    }
}

- (IBAction)addFilterClicked:(id)sender
{
    self.filter = [CIFilter filterWithName:@"CISepiaTone"];
    
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:self.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CIImage *source = [request.sourceImage imageByClampingToExtent];
        // Clamp to avoid blurring transparent pixels at the image edges
        [self.filter setValue:source forKey:kCIInputImageKey];
        
        CIImage *output = [[self.filter outputImage] imageByCroppingToRect:request.sourceImage.extent];
        [request finishWithImage:output context:nil];
    }];
    
    self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    
    [self reloadPlayerView];
}

- (IBAction)addMusicClicked:(id)sender
{
   
    NSString *audioURL = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"m4a"];
    AVAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioURL] options:nil];
    AVAssetTrack *newAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
    
    
    if (!self.composition) {
        NSError *error = nil;
        AVAssetTrack *assetVideoTrack = nil;
        AVAssetTrack *assetAudioTrack = nil;
        
        if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
            assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
        }
        if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
            assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
        }
        
        self.composition = [AVMutableComposition composition];
        
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.asset duration]) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
            compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform;
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.asset duration]) ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
        }
    }

    NSError *error = nil;
    AVMutableCompositionTrack *customAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [customAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.composition duration]) ofTrack:newAudioTrack atTime:kCMTimeZero error:&error];

    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:customAudioTrack];
    [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:CMTimeRangeMake(kCMTimeZero, self.composition.duration)];
    
    self.audioMix = [AVMutableAudioMix audioMix];
    self.audioMix.inputParameters = @[mixParameters];
    
    [self reloadPlayerView];
}

- (void)reloadPlayerView
{
    self.videoComposition.animationTool = NULL;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    if (self.composition) {
        playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
    }
    
    playerItem.videoComposition = self.videoComposition;
    playerItem.audioMix = self.audioMix;
    if(self.watermarkLayer) {
        self.watermarkLayer.position = CGPointMake([[self playerView] bounds].size.width/2, [[self playerView] bounds].size.height/2);
        [[[self playerView] layer] addSublayer:self.watermarkLayer];
    }
    [[self player] replaceCurrentItemWithPlayerItem:playerItem];
    
}

- (IBAction)exportVideoAndSave:(UIBarButtonItem *)sender
{
    
    if (!self.videoComposition) {
        self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.asset];
    }
    
    if (self.watermarkLayer) {
        AVAssetTrack *assetVideoTrack = nil;
        if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
            assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];

        }
        
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
    AVAsset *asset = self.asset;
    if (self.composition) {
        asset = self.composition;
    }
    self.exportSession = [ZYBVideoManager exportVideoWithAsset:asset presetName:presetName videoComposition:self.videoComposition audioMix:self.audioMix outputURL:[[ZYBVideoHelper savaUserPath] stringByAppendingPathComponent:self.fileName] completedBlock:^(NSError *error) {
        [self.timer invalidate];
        self.timer = nil;
        [SVProgressHUD dismiss];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ZYBVideoHelper saveVideo:[[ZYBVideoHelper savaUserPath] stringByAppendingPathComponent:self.fileName]];
        });
        
    }];
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
