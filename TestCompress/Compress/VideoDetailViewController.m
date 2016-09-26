//
//  VideoDetailViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "VideoDetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface VideoDetailViewController (){
    AVAssetExportSession *session;
}
@property (weak, nonatomic) IBOutlet UIButton *compButtonClicked;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (strong, nonatomic) ALAssetRepresentation *assetRepresentation;

@property (weak, nonatomic) IBOutlet UISegmentedControl *qualitySegControl;
@property (strong, nonatomic) NSString *presetName;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fenbianlvLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bpsLabel;


@property (weak, nonatomic) IBOutlet UILabel *compNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *compTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *compressSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressFenbianlvLabel;
@property (weak, nonatomic) IBOutlet UILabel *compFrameRateLable;
@property (weak, nonatomic) IBOutlet UILabel *compBpsLabel;

@property (weak, nonatomic) IBOutlet UILabel *compressCostTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *playCompressButton;
@property (weak, nonatomic) IBOutlet UIButton *saveCompressButton;


@property (strong, nonatomic) NSString *compressVideoPath;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.assetRepresentation = [self.asset defaultRepresentation];
    
    self.qualitySegControl.selectedSegmentIndex = 1;
    self.presetName = AVAssetExportPresetMediumQuality;
    
     AVAssetTrack *track = [self getVideoDetailWithURL:[self.assetRepresentation url]];
    
    self.videoImageView.image = [UIImage imageWithCGImage:[self.assetRepresentation fullScreenImage]];
    
    self.nameLabel.text = [[NSString alloc] initWithFormat:@"名称：%@",[self.assetRepresentation filename]];
    self.timeLabel.text = [[NSString alloc] initWithFormat:@"时长：%d秒", [[self.asset valueForProperty:ALAssetPropertyDuration] intValue]];
    self.sizeLabel.text = [[NSString alloc] initWithFormat:@"大小：%.2fMB", ([self.assetRepresentation size]/1024.0)/1024.0];
    self.fenbianlvLabel.text =[[NSString alloc] initWithFormat:@"分辨率：%dx%d px",(int)track.naturalSize.width, (int)track.naturalSize.height];
    self.frameRateLabel.text = [[NSString alloc] initWithFormat:@"帧率：%.2f",track.nominalFrameRate];
    self.bpsLabel.text = [[NSString alloc] initWithFormat:@"bps：%.2fMbit/s",track.estimatedDataRate/1048576.0];// bits -> Mbits

    self.playCompressButton.enabled = NO;
    self.playCompressButton.alpha = 0.4;
    self.saveCompressButton.enabled = NO;
    self.saveCompressButton.alpha = 0.4;
    
}

/*************************************************************************/
#pragma mark- Action
/*************************************************************************/
- (IBAction)testButtonClicked:(id)sender {

}

- (IBAction)qualitySegControlChange:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.presetName = AVAssetExportPresetLowQuality;
            break;
        case 1:
            self.presetName = AVAssetExportPresetMediumQuality;
            break;
        case 2:
            self.presetName = AVAssetExportPresetHighestQuality;
            break;
    }
}


- (IBAction)compButtonClicked:(id)sender {
    
    self.maskView.hidden = NO;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePregress) userInfo:nil repeats:YES];
    
    [self videoCompressionWithUrl:[NSURL URLWithString:self.videourl]];
}

- (void)updatePregress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text = [[NSString alloc] initWithFormat:@"%d%%",(int)(session.progress*100)];
    });
    
}

- (IBAction)playOrigVideo:(id)sender {
    
    AVPlayerViewController * filePlayerViewController = [AVPlayerViewController alloc];
    //Show the controls
    filePlayerViewController.showsPlaybackControls = true;
    AVURLAsset *ass = [AVURLAsset URLAssetWithURL:[self.assetRepresentation url] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: ass.URL];
    AVPlayer *filePlayer = [AVPlayer playerWithPlayerItem:playerItem];
//    AVPlayer * filePlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videourl]];
    filePlayerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filePlayerViewController.player = filePlayer;
    [self presentViewController:filePlayerViewController animated:YES completion:nil];
}

- (IBAction)playCompressVideo:(id)sender
{
    AVPlayerViewController * filePlayerViewController = [AVPlayerViewController alloc];
    filePlayerViewController.showsPlaybackControls = true;
    AVPlayer * filePlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.compressVideoPath]];
    filePlayerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filePlayerViewController.player = filePlayer;
    [self presentViewController:filePlayerViewController animated:YES completion:nil];
}

- (IBAction)saveCompressVideo:(id)sender {
    [self saveVideo:self.compressVideoPath];
}


#pragma mark - 压缩

-(void)videoCompressionWithUrl:(NSURL *)url{
    
    CFTimeInterval startTime = CACurrentMediaTime();

    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[self.assetRepresentation url] options:nil];
    //创建视频资源导出会话
    session = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:self.presetName];
    //创建导出视频的URL
    self.compressVideoPath = [[self savaUserPath] stringByAppendingPathComponent:[self.assetRepresentation filename]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.compressVideoPath]) {
        [fileManager removeItemAtPath:self.compressVideoPath error:nil];
    }
    
    session.outputURL = [NSURL fileURLWithPath:self.compressVideoPath];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    __weak typeof(self) weakSelf = self;
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        CFTimeInterval endTime = CACurrentMediaTime();
        NSLog(@"Total Runtime: %g s", endTime - startTime);
        NSLog(@"压缩后的视频地址为 %@",self.compressVideoPath);

        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status != AVAssetExportSessionStatusCompleted){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"压缩失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];

                weakSelf.maskView.hidden = YES;
                return;
            }
  
            
            AVAssetTrack *track = [self getVideoDetailWithURL:[NSURL fileURLWithPath:self.compressVideoPath]];
            
            weakSelf.compNameLabel.text = [[NSString alloc] initWithFormat:@"名称：%@",[self.assetRepresentation filename]];
            weakSelf.compTimeLabel.text = [[NSString alloc] initWithFormat:@"时长：%d秒", [[self.asset valueForProperty:ALAssetPropertyDuration] intValue]];
            weakSelf.compressSizeLabel.text = [[NSString alloc] initWithFormat:@"大小：%.2fMB", [self getfileSize:self.compressVideoPath]];
            weakSelf.compressFenbianlvLabel.text =[[NSString alloc] initWithFormat:@"分辨率：%dx%d px",(int)track.naturalSize.width, (int)track.naturalSize.height];
            weakSelf.compFrameRateLable.text = [[NSString alloc] initWithFormat:@"帧率：%.2f",track.nominalFrameRate];
            weakSelf.compBpsLabel.text = [[NSString alloc] initWithFormat:@"bps：%.2fMbit/s",track.estimatedDataRate/1048576.0];
            

            weakSelf.compressCostTimeLabel.text = [[NSString alloc] initWithFormat:@"压缩用时：%.2f秒",endTime - startTime];
            
            weakSelf.playCompressButton.enabled = YES;
            weakSelf.saveCompressButton.enabled = YES;
            weakSelf.playCompressButton.alpha = 1;
            weakSelf.saveCompressButton.alpha = 1;
            weakSelf.maskView.hidden = YES;
        });
    }];
}


#pragma mark- Helper
- (AVAssetTrack *)getVideoDetailWithURL:(NSURL *)url{
    AVAssetTrack *videoTrack = nil;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    CMFormatDescriptionRef formatDescription = NULL;
    NSArray *formatDescriptions = [videoTrack formatDescriptions];
    if ([formatDescriptions count] > 0)
        formatDescription = (__bridge CMFormatDescriptionRef)[formatDescriptions objectAtIndex:0];
    
    if ([videoTracks count] > 0)
        videoTrack = [videoTracks objectAtIndex:0];
    
    CGSize trackDimensions = {
        .width = 0.0,
        .height = 0.0,
    };
    trackDimensions = [videoTrack naturalSize];
    
    int width = trackDimensions.width;
    int height = trackDimensions.height;
    NSLog(@"Resolution = %d X %d",width ,height);
    
    return videoTrack;
}


- (void)saveVideo:(NSString *)videoPath
{
    //    videoPath是你视频文件的路径，我这里是加载工程中的
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                        [alert show];
                                    } else {
                                        NSLog(@"Save video succeed.");
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已经保存到相册" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                        [alert show];
                                        
                                    }
                                }];
}
- (NSString *)savaUserPath{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"compVideo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return path;
}

- (NSString *)origVideoPath{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"origVideo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return path;
}

- (CGFloat)getfileSize:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
    return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
}

@end
